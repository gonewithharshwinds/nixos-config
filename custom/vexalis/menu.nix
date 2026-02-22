{ config, pkgs, ... }:

let
  indexHtml = pkgs.writeText "index.html" ''
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        @font-face {
          font-family: "JetBrainsMono Nerd Font";
          src: local("JetBrainsMono Nerd Font");
        }
        
        * {
          box-sizing: border-box;
          cursor: default; 
        }

        body {
          margin: 0;
          height: 100vh;
          width: 100vw;
          display: flex;
          align-items: center;
          justify-content: center;
          background-color: rgba(0, 0, 0, 0.01); 
          font-family: "JetBrainsMono Nerd Font", sans-serif;
          color: #ffffff;
          overflow: hidden;
        }
        
        /* The Responsive Liquid Glass Container */
        .liquid-glass-menu {
          width: 100vw;
          height: 100vh;
          border-radius: 30px;
          background: rgba(255, 255, 255, 0.05);
          backdrop-filter: url(#liquidGlassFilterId) blur(15px);
          border: 1.5px solid rgba(255, 255, 255, 0.3);
          box-shadow: 
            inset 0 0 20px rgba(255, 255, 255, 0.1),
            0 25px 50px rgba(0, 0, 0, 0.5);
          display: flex;
          flex-direction: column;
          padding: 50px;
        }

        #search {
          width: 100%;
          padding: 25px 35px;
          border-radius: 25px;
          border: 1px solid rgba(255, 255, 255, 0.2);
          background: rgba(0, 0, 0, 0.3);
          color: #fff;
          font-size: 2rem;
          outline: none;
          box-shadow: inset 0 4px 10px rgba(0,0,0,0.3);
          font-family: "JetBrainsMono Nerd Font", sans-serif;
          margin-bottom: 40px;
          cursor: text;
        }
        #search::placeholder { color: rgba(255, 255, 255, 0.4); }

        #app-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
          grid-auto-rows: 150px;
          gap: 25px;
          overflow-y: auto;
          padding: 10px;
          padding-right: 20px;
        }
        
        #app-grid::-webkit-scrollbar { width: 0px; }

        .app-card {
          background: rgba(255, 255, 255, 0.06);
          border: 1px solid rgba(255, 255, 255, 0.15);
          border-radius: 24px;
          padding: 15px;
          text-align: center;
          cursor: pointer;
          transition: all 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.94);
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .app-card:hover, .app-card.selected {
          background: rgba(255, 255, 255, 0.2);
          border: 1px solid rgba(255, 255, 255, 0.6);
          transform: scale(1.05) translateY(-5px);
          box-shadow: 0 15px 30px rgba(0,0,0,0.4);
        }

        .app-icon {
          width: 72px;
          height: 72px;
          margin-bottom: 15px;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        
        .app-icon img {
          max-width: 100%;
          max-height: 100%;
          object-fit: contain;
          filter: drop-shadow(0px 4px 6px rgba(0,0,0,0.4));
        }

        .app-name {
          font-size: 1rem;
          font-weight: 600;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          width: 100%;
          text-shadow: 0px 2px 4px rgba(0,0,0,0.8);
        }
      </style>
    </head>
    <body>

      <svg width="0" height="0" style="position: absolute;">
        <filter id="liquidGlassFilterId" x="0" y="0" width="100%" height="100%" color-interpolation-filters="sRGB">
          <feImage id="dispMap" href="" result="displacement_map" x="0" y="0" width="100%" height="100%" />
          <feDisplacementMap in="SourceGraphic" in2="displacement_map" scale="50" xChannelSelector="R" yChannelSelector="G" result="refracted" />
        </filter>
      </svg>

      <div class="liquid-glass-menu">
        <input type="text" id="search" placeholder="Type to search..." autofocus>
        <div id="app-grid"></div>
      </div>

      <script>
        const fs = require("fs");
        const os = require("os");
        const path = require("path");
        const { exec } = require("child_process");

        function generateLiquidGlassMap(width, height, radius, bezel) {
          const canvas = document.createElement("canvas");
          canvas.width = width; canvas.height = height;
          const ctx = canvas.getContext("2d");
          const imgData = ctx.createImageData(width, height);

          function distToInnerEdge(x, y) {
            const cx = Math.max(0, Math.abs(x - width/2) - (width/2 - radius));
            const cy = Math.max(0, Math.abs(y - height/2) - (height/2 - radius));
            const d = Math.sqrt(cx*cx + cy*cy);
            return radius - d; 
          }

          for (let y = 0; y < height; y++) {
            for (let x = 0; x < width; x++) {
              const d = distToInnerEdge(x, y);
              let dx = 0, dy = 0;

              if (d > 0 && d < bezel) {
                const nx = d / bezel; 
                const derivative = Math.pow(1 - nx, 3) / Math.pow(1 - Math.pow(1 - nx, 4) + 0.001, 0.75);
                const dirX = (width/2 - x);
                const dirY = (height/2 - y);
                const len = Math.sqrt(dirX*dirX + dirY*dirY);
                dx = (dirX / len) * derivative;
                dy = (dirY / len) * derivative;
              }

              const i = (y * width + x) * 4;
              imgData.data[i] = Math.max(0, Math.min(255, 128 + dx * 127)); 
              imgData.data[i+1] = Math.max(0, Math.min(255, 128 + dy * 127)); 
              imgData.data[i+2] = 128;
              imgData.data[i+3] = 255;
            }
          }
          ctx.putImageData(imgData, 0, 0);
          return canvas.toDataURL("image/png");
        }

        function applyGlass() {
          const w = window.innerWidth;
          const h = window.innerHeight;
          const dispMap = document.getElementById("dispMap");
          if(dispMap && w > 0 && h > 0) {
            dispMap.setAttribute("width", w);
            dispMap.setAttribute("height", h);
            dispMap.setAttribute("href", generateLiquidGlassMap(w, h, 40, 80));
          }
        }

        window.addEventListener("resize", applyGlass);
        setTimeout(applyGlass, 50); 

        // --- FIXED: ADD HOME MANAGER AND LOCAL PATHS ---
        const homeDir = os.homedir();
        const userName = os.userInfo().username;

        const appDirs = [
          "/run/current-system/sw/share/applications/",
          "/etc/profiles/per-user/" + userName + "/share/applications/",
          homeDir + "/.nix-profile/share/applications/",
          homeDir + "/.local/share/applications/"
        ];

        let systemApps = [];
        let selectedIndex = 0;

        function resolveIcon(iconName) {
          if (!iconName) return null;
          if (iconName.startsWith("/")) return iconName;
          
          const searchPaths = [
            "/run/current-system/sw/share/icons/Papirus/64x64/apps/" + iconName + ".svg",
            "/run/current-system/sw/share/icons/hicolor/scalable/apps/" + iconName + ".svg",
            "/run/current-system/sw/share/icons/hicolor/48x48/apps/" + iconName + ".png",
            "/run/current-system/sw/share/pixmaps/" + iconName + ".png",
            "/run/current-system/sw/share/pixmaps/" + iconName + ".svg",
            "/etc/profiles/per-user/" + userName + "/share/icons/Papirus/64x64/apps/" + iconName + ".svg",
            "/etc/profiles/per-user/" + userName + "/share/icons/hicolor/scalable/apps/" + iconName + ".svg",
            "/etc/profiles/per-user/" + userName + "/share/icons/hicolor/48x48/apps/" + iconName + ".png",
            homeDir + "/.nix-profile/share/icons/Papirus/64x64/apps/" + iconName + ".svg",
            homeDir + "/.nix-profile/share/icons/hicolor/scalable/apps/" + iconName + ".svg",
            homeDir + "/.nix-profile/share/icons/hicolor/48x48/apps/" + iconName + ".png"
          ];
          
          for (let i = 0; i < searchPaths.length; i++) {
            if (fs.existsSync(searchPaths[i])) return searchPaths[i];
          }
          return null;
        }

        // Loop through all directories
        appDirs.forEach(dir => {
          if (fs.existsSync(dir)) {
            const files = fs.readdirSync(dir).filter(f => f.endsWith(".desktop"));
            files.forEach(file => {
              const content = fs.readFileSync(dir + file, "utf-8");
              
              const nameMatch = content.match(/^Name=(.*)$/m);
              const execMatch = content.match(/^Exec=(.*)$/m);
              const iconMatch = content.match(/^Icon=(.*)$/m);
              const noDisp = content.match(/^NoDisplay=true$/m);
              
              if (nameMatch && execMatch && !noDisp) {
                // BUG FIX: Added [1] to correctly capture regex group contents
                const cleanCmd = execMatch[1].replace(/%[a-zA-Z]/g, "").trim();
                const iconPath = iconMatch ? resolveIcon(iconMatch[1].trim()) : null;
                
                systemApps.push({ 
                  name: nameMatch[1].trim(), 
                  cmd: cleanCmd,
                  icon: iconPath 
                });
              }
            });
          }
        });

        systemApps = systemApps.filter((v,i,a)=>a.findIndex(t=>(t.name === v.name))===i);
        systemApps.sort((a,b) => a.name.localeCompare(b.name));

        const grid = document.getElementById("app-grid");
        const search = document.getElementById("search");

        function renderApps(filterText) {
          grid.innerHTML = "";
          const searchText = filterText ? filterText.toLowerCase() : "";
          const filtered = systemApps.filter(app => app.name.toLowerCase().includes(searchText));
          
          filtered.forEach((app, index) => {
            const card = document.createElement("div");
            card.className = "app-card" + (index === selectedIndex ? " selected" : "");
            
            let iconHtml = "<div class=\"app-icon\">";
            if (app.icon) {
              iconHtml += "<img src=\"file://" + app.icon + "\">";
            } else {
              iconHtml += "<span style=\"font-size: 3rem;\">📱</span>";
            }
            iconHtml += "</div>";
            
            card.innerHTML = iconHtml + "<div class=\"app-name\">" + app.name + "</div>";
            card.onclick = () => launchApp(app.cmd);
            grid.appendChild(card);
            
            if (index === selectedIndex) {
              card.scrollIntoView({ behavior: "smooth", block: "nearest" });
            }
          });
        }

        function launchApp(cmd) {
          const safeCmd = cmd.replace(/"/g, '\\"');
          exec("hyprctl dispatch exec \"" + safeCmd + "\"");
          window.close(); 
        }

        search.addEventListener("keyup", (e) => {
          const filtered = systemApps.filter(app => app.name.toLowerCase().includes(search.value.toLowerCase()));
          
          if (e.key === "Enter" && filtered.length > 0) {
            launchApp(filtered[selectedIndex].cmd);
          } else if (e.key === "ArrowRight") {
            selectedIndex = Math.min(selectedIndex + 1, filtered.length - 1);
            renderApps(search.value);
          } else if (e.key === "ArrowLeft") {
            selectedIndex = Math.max(selectedIndex - 1, 0);
            renderApps(search.value);
          } else if (e.key === "ArrowDown") {
            selectedIndex = Math.min(selectedIndex + 6, filtered.length - 1);
            renderApps(search.value);
          } else if (e.key === "ArrowUp") {
            selectedIndex = Math.max(selectedIndex - 6, 0);
            renderApps(search.value);
          } else if (e.key === "Escape") {
            window.close();
          } else {
            selectedIndex = 0;
            renderApps(search.value);
          }
        });

        renderApps("");
      </script>
    </body>
    </html>
  '';

  mainJs = pkgs.writeText "main.js" ''
    const { app, BrowserWindow } = require("electron");

    app.on("ready", () => {
      const win = new BrowserWindow({
        width: 1200,
        height: 800,
        transparent: true,
        frame: false,
        skipTaskbar: true,
        alwaysOnTop: true,
        resizable: true,
        webPreferences: { 
          nodeIntegration: true,
          contextIsolation: false
        }
      });
      
      win.loadFile("index.html");
      
      win.on("blur", () => {
        app.quit();
      });
    });
  '';

  vexalisMenu = pkgs.stdenv.mkDerivation {
    pname = "vexalisMenu";
    version = "1.0.0";

    src = pkgs.writeText "dummy" "";
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin $out/share/vexalisMenu

      cp ${indexHtml} $out/share/vexalisMenu/index.html
      cp ${mainJs} $out/share/vexalisMenu/main.js

      cat > $out/bin/vexalisMenu <<EOF
      #!/bin/sh
      export XCURSOR_THEME="Bibata-Modern-Classic"
      export XCURSOR_SIZE="24"
      exec ${pkgs.electron}/bin/electron $out/share/vexalisMenu/main.js --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-transparent-visuals
      EOF
      
      chmod +x $out/bin/vexalisMenu
    '';
  };
in
{
  home.packages = [ vexalisMenu ];
}
