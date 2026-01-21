import App from 'resource:///com/github/Aylur/ags/app.js';
import Utils from 'resource:///com/github/Aylur/ags/utils.js';
import BentoLauncher from './widgets/BentoLauncher.js';

// --- PATHS ---
const scss = `${App.configDir}/style.scss`;
const css = `${App.configDir}/style.css`;
const colors = `${App.configDir}/colors.css`;

// --- SAFETY CHECKS ---

// 1. Ensure colors.css exists
// If 'update-theme.sh' hasn't run, style.scss will fail to compile because of the import.
// We create a fallback file to prevent the app from crashing.
if (!Utils.readFile(colors)) {
    console.log("⚠️ colors.css not found. Generating fallback.");
    Utils.writeFile(`
        @define-color md-sys-color-primary #6750a4;
        @define-color md-sys-color-on-primary #ffffff;
        @define-color md-sys-color-primary-container #eaddff;
        @define-color md-sys-color-on-primary-container #21005d;
        @define-color md-sys-color-secondary-container #e8def8;
        @define-color md-sys-color-on-secondary-container #1d192b;
        @define-color md-sys-color-surface #fffbfe;
        @define-color md-sys-color-on-surface #1c1b1f;
        @define-color md-sys-color-surface-variant #e7e0ec;
        @define-color md-sys-color-on-surface-variant #49454f;
        @define-color md-sys-color-surface-container-high #ece6f0;
        @define-color md-sys-color-surface-container-highest #e6e0e9;
        @define-color md-sys-color-outline-variant #cac4d0;
        @define-color md-sys-color-tertiary #7d5260;
        @define-color md-sys-color-on-tertiary #ffffff;
    `, colors);
}

// 2. Compile SCSS
function compileSass() {
    try {
        // Compile imports the colors.css we ensured exists above
        Utils.exec(`sassc ${scss} ${css}`);
        console.log("✅ SCSS Compiled successfully");
    } catch (error) {
        console.error("❌ SCSS Compile Failed:", error);
        // Write minimal CSS so the app doesn't crash on empty file
        Utils.writeFile('window { background-color: rgba(0,0,0,0.5); color: red; }', css);
    }
}

// Initial Compile
compileSass();

// --- RELOAD LOGIC ---
// Monitor SCSS for changes to live-reload styles
Utils.monitorFile(
    `${App.configDir}/style.scss`,
    function() {
        compileSass();
        App.resetCss();
        App.applyCss(css);
    },
);

// --- MAIN APP CONFIG ---
// We use App.config() instead of export default to fix the deprecation warning
App.config({
    style: css,
    windows: [
        BentoLauncher(),
    ],
});