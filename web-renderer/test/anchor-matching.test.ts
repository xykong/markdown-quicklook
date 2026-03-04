describe('Anchor Matching with Five-Level Tolerant Strategy', () => {
    function compressMultipleHyphens(text: string): string {
        return text.replace(/-+/g, '-');
    }

    function unifyUnderscoreAndHyphen(text: string): string {
        return text.replace(/[_-]/g, '~');
    }

    function stripHyphens(text: string): string {
        return text.toLowerCase().replace(/-/g, '');
    }

    function stripHyphensAndUnderscores(text: string): string {
        return text.toLowerCase().replace(/[-_]/g, '');
    }

    function findElementByAnchorMock(anchorId: string, availableIds: string[]): string | null {
        if (availableIds.includes(anchorId)) {
            return anchorId;
        }
        
        const level2NormalizedTarget = compressMultipleHyphens(anchorId);
        for (const id of availableIds) {
            if (compressMultipleHyphens(id) === level2NormalizedTarget) {
                return id;
            }
        }
        
        const level3NormalizedTarget = unifyUnderscoreAndHyphen(compressMultipleHyphens(anchorId));
        for (const id of availableIds) {
            if (unifyUnderscoreAndHyphen(compressMultipleHyphens(id)) === level3NormalizedTarget) {
                return id;
            }
        }

        // Level 4: strip all hyphens (AI-generated anchors omit hyphens at CJK/ASCII boundaries)
        const level4Target = stripHyphens(anchorId);
        for (const id of availableIds) {
            if (stripHyphens(id) === level4Target) {
                return id;
            }
        }

        // Level 5: strip all hyphens and underscores (most permissive fallback)
        const level5Target = stripHyphensAndUnderscores(anchorId);
        for (const id of availableIds) {
            if (stripHyphensAndUnderscores(id) === level5Target) {
                return id;
            }
        }
        
        return null;
    }

    it('should match exact anchor IDs', () => {
        const availableIds = ['section-one', 'section-two', 'facility-类型概览'];
        
        expect(findElementByAnchorMock('section-one', availableIds)).toBe('section-one');
        expect(findElementByAnchorMock('facility-类型概览', availableIds)).toBe('facility-类型概览');
    });

    it('should match anchors with multiple consecutive hyphens', () => {
        const availableIds = [
            'app_metrics-应用性能监控',
            'backend_callback-后端回调追踪',
            'section-two'
        ];
        
        expect(findElementByAnchorMock('app_metrics---应用性能监控', availableIds)).toBe('app_metrics-应用性能监控');
        expect(findElementByAnchorMock('backend_callback---后端回调追踪', availableIds)).toBe('backend_callback-后端回调追踪');
        expect(findElementByAnchorMock('section---two', availableIds)).toBe('section-two');
    });

    it('should handle Chinese characters correctly', () => {
        const availableIds = ['中文标题测试', '高离散度字段说明'];
        
        expect(findElementByAnchorMock('中文标题测试', availableIds)).toBe('中文标题测试');
        expect(findElementByAnchorMock('高离散度字段说明', availableIds)).toBe('高离散度字段说明');
    });

    it('should handle mixed Latin and Chinese with hyphens', () => {
        const availableIds = [
            'app_metrics-应用性能监控',
            'backend-prod-后端生产日志',
            'plog-性能监控'
        ];
        
        expect(findElementByAnchorMock('app_metrics---应用性能监控', availableIds)).toBe('app_metrics-应用性能监控');
        expect(findElementByAnchorMock('backend-prod---后端生产日志', availableIds)).toBe('backend-prod-后端生产日志');
        expect(findElementByAnchorMock('plog---性能监控', availableIds)).toBe('plog-性能监控');
    });

    it('should return null for non-existent anchors', () => {
        const availableIds = ['section-one', 'section-two'];
        
        expect(findElementByAnchorMock('non-existent', availableIds)).toBeNull();
        expect(findElementByAnchorMock('section-three', availableIds)).toBeNull();
    });

    it('should prefer exact matches over normalized matches', () => {
        const availableIds = ['section--two', 'section-two'];
        
        expect(findElementByAnchorMock('section--two', availableIds)).toBe('section--two');
    });

    it('should match underscore and hyphen as equivalent (level 3)', () => {
        const availableIds = [
            'backend-callback-后端回调追踪',
            'anipop_exporter-日志采集服务'
        ];
        
        expect(findElementByAnchorMock('backend_callback---后端回调追踪', availableIds)).toBe('backend-callback-后端回调追踪');
        expect(findElementByAnchorMock('anipop-exporter---日志采集服务', availableIds)).toBe('anipop_exporter-日志采集服务');
    });

    it('should prioritize exact match over level 2 and level 3 normalization', () => {
        const availableIds = [
            'backend_callback-后端回调追踪',
            'backend-callback-后端回调追踪'
        ];
        
        expect(findElementByAnchorMock('backend_callback---后端回调追踪', availableIds)).toBe('backend_callback-后端回调追踪');
    });

    it('should prioritize level 2 (hyphen compression) over level 3 (underscore unification)', () => {
        const availableIds = [
            'section---two',
            'section_two'
        ];
        
        expect(findElementByAnchorMock('section---two', availableIds)).toBe('section---two');
    });

    it('should handle real-world TOC link cases from graylog_business_fields.md', () => {
        const availableIds = [
            'facility-类型概览',
            'app_metrics-应用性能监控',
            'backend_callback-后端回调追踪',
            'backend_prod-后端生产日志',
            'anipop_exporter-日志采集服务',
            'animal_locks_k8s-锁任务调度',
            'plog-性能监控',
            'web_console-web-控制台',
            '高离散度字段说明'
        ];
        
        expect(findElementByAnchorMock('facility-类型概览', availableIds)).toBe('facility-类型概览');
        expect(findElementByAnchorMock('app_metrics---应用性能监控', availableIds)).toBe('app_metrics-应用性能监控');
        expect(findElementByAnchorMock('backend_callback---后端回调追踪', availableIds)).toBe('backend_callback-后端回调追踪');
        expect(findElementByAnchorMock('backend_prod---后端生产日志', availableIds)).toBe('backend_prod-后端生产日志');
        expect(findElementByAnchorMock('anipop_exporter---日志采集服务', availableIds)).toBe('anipop_exporter-日志采集服务');
        expect(findElementByAnchorMock('animal_locks_k8s---锁任务调度', availableIds)).toBe('animal_locks_k8s-锁任务调度');
        expect(findElementByAnchorMock('plog---性能监控', availableIds)).toBe('plog-性能监控');
        expect(findElementByAnchorMock('web_console---web-控制台', availableIds)).toBe('web_console-web-控制台');
        expect(findElementByAnchorMock('高离散度字段说明', availableIds)).toBe('高离散度字段说明');
    });

    // =======================================================================
    // Level 4: AI-generated anchors (strip hyphens to compare)
    // AI tools (e.g. Cursor, GitHub Copilot) use a different slugify algorithm:
    // they strip special chars but don't insert hyphens at CJK/ASCII boundaries.
    // e.g. link: "故障-6镜像拉取卡死containerd-ingest-残留"
    //     vs actual ID: "故障-6-镜像拉取卡死-containerd-ingest-残留"
    // =======================================================================

    it('should match AI-generated anchors that omit hyphens at CJK/ASCII boundaries (level 4)', () => {
        // Real examples from TROUBLESHOOTING.md generated by AI tools
        const availableIds = [
            '故障-6-镜像拉取卡死-containerd-ingest-残留',
            '故障-7-kubectl-apply-报-pdb-v1beta1-不存在',
            '故障-21-kubectl-apply-报-ingress-hpa-v1beta1-不存在-k8s-1-26-api-变更',
            '故障-37-webservice-pod-重启后镜像拉取慢',
        ];

        // AI-generated anchors (missing hyphens at CJK/ASCII boundaries)
        expect(findElementByAnchorMock('故障-6镜像拉取卡死containerd-ingest-残留', availableIds))
            .toBe('故障-6-镜像拉取卡死-containerd-ingest-残留');
        expect(findElementByAnchorMock('故障-7kubectl-apply-报-pdb-v1beta1-不存在', availableIds))
            .toBe('故障-7-kubectl-apply-报-pdb-v1beta1-不存在');
        expect(findElementByAnchorMock('故障-37webservice-pod-重启后镜像拉取慢', availableIds))
            .toBe('故障-37-webservice-pod-重启后镜像拉取慢');
    });

    it('should match AI-generated anchors with complex special char differences (level 4)', () => {
        // Complex case: '/' and other chars stripped vs replaced
        // Heading: 故障 21：kubectl apply 报 Ingress/HPA v1beta1 不存在（K8s 1.26+ API 变更）
        // Our slug: 故障-21-kubectl-apply-报-ingress-hpa-v1beta1-不存在-k8s-1-26-api-变更
        // AI link:  故障-21kubectl-apply-报-ingresshpa-v1beta1-不存在k8s-126-api-变更
        const availableIds = ['故障-21-kubectl-apply-报-ingress-hpa-v1beta1-不存在-k8s-1-26-api-变更'];

        expect(findElementByAnchorMock('故障-21kubectl-apply-报-ingresshpa-v1beta1-不存在k8s-126-api-变更', availableIds))
            .toBe('故障-21-kubectl-apply-报-ingress-hpa-v1beta1-不存在-k8s-1-26-api-变更');
    });

    it('should match AI-generated anchors with underscores replacing hyphens (level 5)', () => {
        // Level 5: strip both hyphens and underscores
        // e.g. anchor uses underscore where actual has hyphen, AND missing boundary hyphens
        const availableIds = ['故障-6-镜像拉取卡死-containerd-ingest-残留'];

        // Mixed: has underscores and missing boundary hyphens
        expect(findElementByAnchorMock('故障_6镜像拉取卡死containerd_ingest_残留', availableIds))
            .toBe('故障-6-镜像拉取卡死-containerd-ingest-残留');
    });

    it('should not match completely different anchors even with level 4/5', () => {
        const availableIds = ['故障-6-镜像拉取卡死', '数据库连接失败'];

        expect(findElementByAnchorMock('网络超时', availableIds)).toBeNull();
        expect(findElementByAnchorMock('completely-different-section', availableIds)).toBeNull();
    });

    it('should prefer more specific matches (level 1 > 2 > 3 > 4 > 5)', () => {
        // When level 4 matches but level 1 is available, should pick level 1
        const availableIds = [
            '故障-6-镜像',   // actual slug (closer to reality)
            '故障6镜像',     // hypothetical ID without hyphens
        ];

        // Exact match wins
        expect(findElementByAnchorMock('故障-6-镜像', availableIds)).toBe('故障-6-镜像');
        // AI-style link should match via level 4 (故障6镜像 exists as exact match)
        expect(findElementByAnchorMock('故障6镜像', availableIds)).toBe('故障6镜像');
    });
});
