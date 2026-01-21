import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import App from 'resource:///com/github/Aylur/ags/app.js';
import Applications from 'resource:///com/github/Aylur/ags/service/applications.js';
import Variable from 'resource:///com/github/Aylur/ags/variable.js';
import Mpris from 'resource:///com/github/Aylur/ags/service/mpris.js';
import { execAsync } from 'resource:///com/github/Aylur/ags/utils.js';

// --- DATA & STATE ---

// Define your keybind hints here
const SHORTCUT_HINTS = {
    'kitty': ' Q',
    'thunar': ' E',
    'firefox': '',
    'vivaldi-stable': '',
    'discord': '',
};

// Greeting logic
const user = Variable('H4rsh', {
    poll: [60000, 'whoami', out => out.trim().charAt(0).toUpperCase() + out.trim().slice(1)]
});

const time = Variable('', {
    poll: [1000, 'date "+%H:%M"'],
});

const date = Variable('', {
    poll: [60000, 'date "+%A, %B %d"'],
});

// --- WIDGETS ---

// 1. PROFILE & GREETING CARD (Large Bento Box)
const ProfileCard = () => Widget.Box({
    class_name: 'bento-box profile-card',
    vertical: true,
    hexpand: true,
    children: [
        Widget.Box({
            spacing: 12,
            children: [
                Widget.Icon({
                    icon: '/home/h4rsh/Downloads/bento.png', // Or path to your face.png
                    size: 42,
                    class_name: 'profile-icon',
                }),
                Widget.Box({
                    vertical: true,
                    vpack: 'center',
                    children: [
                        Widget.Label({
                            class_name: 'greeting-text',
                            xalign: 0,
                            label: user.bind().transform(u => `Good Day, ${u}`),
                        }),
                        Widget.Label({
                            class_name: 'status-text',
                            xalign: 0,
                            label: 'Ready to ship code?',
                        }),
                    ],
                }),
            ],
        }),
        Widget.Box({ vpack: 'end', vexpand: true, css: 'min-height: 20px;' }), // Spacer
        Widget.Label({
            class_name: 'clock-huge',
            xalign: 1,
            label: time.bind(),
        }),
        Widget.Label({
            class_name: 'date-small',
            xalign: 1,
            label: date.bind(),
        }),
    ],
});

// 2. MEDIA CARD (Medium Bento Box)
const MediaCard = () => Widget.Box({
    class_name: 'bento-box media-card',
    vertical: true,
    hexpand: true,
    visible: Mpris.bind('players').transform(p => p.length > 0),
    children: [
        Widget.Box({
            spacing: 10,
            children: [
                Widget.Label({ 
                    class_name: 'media-icon', 
                    label: '' // Music note
                }), 
                Widget.Label({
                    class_name: 'media-title',
                    xalign: 0,
                    truncate: 'end',
                    label: Mpris.bind('players').transform(p => p[0] ? p[0].track_title : 'No Music'),
                }),
            ],
        }),
        Widget.Label({
            class_name: 'media-artist',
            xalign: 0,
            truncate: 'end',
            label: Mpris.bind('players').transform(p => p[0] ? p[0].track_artists.join(', ') : ''),
        }),
        Widget.CenterBox({
            class_name: 'media-controls',
            start_widget: Widget.Button({
                on_clicked: () => Mpris.players[0]?.previous(),
                child: Widget.Label('⏮'),
            }),
            center_widget: Widget.Button({
                on_clicked: () => Mpris.players[0]?.playPause(),
                child: Widget.Label('⏯'),
            }),
            end_widget: Widget.Button({
                on_clicked: () => Mpris.players[0]?.next(),
                child: Widget.Label('⏭'),
            }),
        })
    ],
});

// 3. APP ITEM (The smart ones with hints)
const AppItem = (app) => Widget.Button({
    class_name: 'app-item',
    on_clicked: () => {
        App.closeWindow('bento_launcher');
        app.launch();
    },
    attribute: { app },
    child: Widget.Box({
        vertical: true,
        spacing: 8,
        children: [
            Widget.Overlay({
                child: Widget.Icon({
                    icon: app.icon_name || '',
                    size: 48,
                }),
                overlays: [
                    // The Magical Shortcut Hint
                    SHORTCUT_HINTS[app.app_name] || SHORTCUT_HINTS[app.icon_name] ? Widget.Label({
                        class_name: 'shortcut-hint',
                        hpack: 'end',
                        vpack: 'start',
                        label: SHORTCUT_HINTS[app.app_name] || SHORTCUT_HINTS[app.icon_name],
                    }) : Widget.Box(),
                ]
            }),
            Widget.Label({
                class_name: 'app-name',
                label: app.name,
                truncate: 'end',
                max_width_chars: 12,
            }),
        ],
    }),
});

// 4. THE MAIN GRID LOGIC
const AppGrid = () => {
    // State for the list of apps
    const apps = Variable(Applications.query(''));

    // The Grid container
    const grid = Widget.FlowBox({
        class_name: 'app-grid',
        homogeneous: true,
        max_children_per_line: 5,
        min_children_per_line: 5,
        selection_mode: 0, // None
        setup: self => {
            self.hook(apps, () => {
                self.get_children().forEach(ch => ch.destroy());
                apps.value.forEach(app => {
                    self.add(AppItem(app));
                });
                self.show_all();
            });
        },
    });

    // The Search Bar
    const entry = Widget.Entry({
        class_name: 'search-bar',
        placeholder_text: 'Search Apps...',
        hexpand: true,
        on_change: ({ text }) => {
            // Filter apps
            const results = Applications.query(text || '');
            apps.value = results;
        },
        on_accept: ({ text }) => {
            const results = Applications.query(text || '');
            if (results[0]) {
                App.closeWindow('bento_launcher');
                results[0].launch();
            }
        },
    });

    return Widget.Box({
        vertical: true,
        spacing: 16,
        children: [
            entry,
            Widget.Scrollable({
                hscroll: 'never',
                vscroll: 'automatic',
                css: 'min-height: 400px;',
                child: grid,
            }),
        ],
    });
};


// --- LAYOUT ASSEMBLY ---

const BentoLayout = () => Widget.Box({
    class_name: 'bento-container',
    spacing: 16,
    children: [
        // LEFT COLUMN (Sidebar / Featured)
        Widget.Box({
            vertical: true,
            spacing: 16,
            class_name: 'left-column',
            children: [
                ProfileCard(),
                MediaCard(),
                Widget.Box({
                     class_name: 'bento-box system-box',
                     vertical: true,
                     children: [
                        Widget.Label({ label: 'System', class_name: 'box-title' }),
                        Widget.Label({ label: 'CPU: ' + '12%', class_name: 'sys-text' }), // Replace with real variable if desired
                        Widget.Label({ label: 'RAM: ' + '4.2GB', class_name: 'sys-text' }),
                     ]
                })
            ],
        }),
        // RIGHT COLUMN (Apps)
        Widget.Box({
            vertical: true,
            hexpand: true,
            class_name: 'right-column',
            children: [
                AppGrid(),
            ],
        }),
    ],
});


export default () => Widget.Window({
    name: 'bento_launcher',
    // Position it center or covering screen. 
    // "slide_top" requires anchor "top" usually, but let's do center floating
    anchor: [], // Empty anchor = center
    margins: [0, 0],
    keymode: 'on-demand',
    visible: false,
    child: Widget.Box({
        css: 'padding: 1px;', // Hack to prevent clipping
        child: BentoLayout(),
    }),
    setup: self => self.keybind('Escape', () => {
        App.closeWindow('bento_launcher');
    }),
});