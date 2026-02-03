import { App, Widget, Window } from "resource:///com/github/Aylur/ags/widget.js";

// A dummy Bento Launcher window
const BentoLauncher = () => Window({
    name: "bento_launcher",
    anchor: ["center"],
    visible: false, // Start hidden, toggle with Super+G
    child: Widget.Box({
        className: "launcher-box",
        css: "padding: 50px; background-color: #1e1e2e; border-radius: 20px;",
        children: [
            Widget.Label({
                label: "Bento Launcher Placeholder",
                css: "color: white; font-size: 24px;"
            })
        ],
    }),
});

App.config({
    style: "./style.css",
    windows: [
        BentoLauncher(),
    ],
});