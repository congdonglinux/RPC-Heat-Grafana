define(['settings'],
function (Settings) {
    return new Settings({
        datasources: {
            graphite: {
                type: 'graphite',
                url: 'https://'+window.location.hostname+'/graphite',
            },
                elasticsearch: {
                type: 'elasticsearch',
                url: 'https://'+window.location.hostname+'/elasticsearch',
                index: 'grafana-dash',
                grafanaDB: true,
            }
        },
        search: {
            max_results: 20
        },
        default_route: '/dashboard/script/default.js',
        unsaved_changes_warning: true,
        playlist_timespan: '1m',
        admin: {
            password: ''
        }
        //},
        //plugins: {
        //    panels: ['warning']
        //}
    });
});
