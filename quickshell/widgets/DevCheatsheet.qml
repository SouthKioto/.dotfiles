// Ściąga terminala (prawy dolny róg): moje aliasy/funkcje z ~/.config/fish/config.fish,
// zainstalowane narzędzia CLI/TUI i skrót notatki Obsidian
// Terminal/10 - Narzędzia deweloperskie.md — klik w tytuł ją otwiera.
// Max ~9 wierszy na kategorię, żeby karta nie zmieniała mocno wysokości.
// Kategoria: klik w zakładkę albo kółko myszy nad kartą.
import Quickshell
import QtQuick
import QtQuick.Layouts

Card {
    id: card
    property int category: 0
    readonly property string font: "JetBrainsMono Nerd Font Propo"
    readonly property string note: "/home/kioto/Dokumenty/obsidian-notes/KURS Terminal/10 - Narzędzia deweloperskie.md"

    readonly property var categories: [
        // ── moje (fish) ──
        { name: "Fish", items: [
            ["y", "yazi, po wyjściu cd do katalogu"],
            ["z kat / zi", "zoxide: skok / wybór z listy"],
            ["fzf · fif fraza", "plik z podglądem → nvim · szukaj w treści"],
            ["Ctrl+R · Ctrl+T · Alt+C", "historia (atuin) · plik · katalog"],
            ["ls · la · ll · lt", "eza: lista / +ukryte+git / drzewo"],
            ["mkcd kat", "mkdir -p + cd"],
            [".. · ... · n · cls", "w górę · 2× w górę · nvim · clear"],
            ["cheatsh temat pytanie", "cheat.sh (np. cheatsh tar extract)"],
            ["ffish · zz", "cd do configu fish · zellij"],
        ] },
        { name: "Git", items: [
            ["gs", "status -sb"],
            ["ga plik · gaa", "add · add -A"],
            ["gc \"msg\" · gca", "commit -m · commit --amend"],
            ["gp · gpl", "push · pull --rebase"],
            ["gl", "log --oneline --graph (20)"],
            ["gd · gds", "diff · diff --staged"],
            ["gsw gałąź", "git switch"],
            ["lg", "lazygit"],
            ["gh pr create · gh pr list", "GitHub CLI"],
        ] },
        { name: "Pakiety", items: [
            ["upall", "yay -Syu: system + AUR"],
            ["pacinst · pacrem", "pacman -S · -Rns"],
            ["pacse · yayse", "szukaj w repo · w AUR"],
            ["yayin", "yay -S (AUR)"],
            ["pacqi · pacql", "info · pliki pakietu"],
            ["pacqe", "jawnie zainstalowane"],
            ["orphans", "usuń osierocone pakiety"],
            ["pcache", "cache pacmana (zostaw 2)"],
            ["pacupd · yayupd", "tylko repo · tylko AUR"],
        ] },
        { name: "System", items: [
            ["sc · scu", "systemctl · systemctl --user"],
            ["jc usługa · jb", "logi usługi · błędy z bootu"],
            ["ports", "ss -tulpn: kto słucha"],
            ["myip", "publiczne IP"],
            ["duh · pss", "dust: miejsce · procs po CPU"],
            ["pp-perf · pp-bal · pp-save", "profil zasilania (pp-auto: auto)"],
            ["tlps · bat0", "status TLP · % baterii"],
            ["btop · ff", "monitor zasobów · fastfetch"],
            ["inxi -Fz", "pełne info o sprzęcie"],
        ] },
        { name: "Hypr", items: [
            ["hr · hm · hc", "hyprctl reload / monitors / clients"],
            ["clip · paste", "wl-copy · wl-paste"],
            ["btui · wire · wific", "bluetooth · dźwięk · Wi-Fi (TUI)"],
            ["qs -c widgets log", "logi widżetów pulpitu"],
            ["hyprpicker -a", "pipeta koloru → schowek"],
            ["br skrypt · bd", "bun run · bun run dev"],
            ["pyv", "uv venv + aktywacja"],
            ["mise use node@22", "wersje narzędzi per projekt"],
            ["lampp · lstart · lstop", "XAMPP: katalog / start / stop"],
        ] },
        // ── zainstalowane narzędzia ──
        { name: "CLI", items: [
            ["rg wzorzec", "ripgrep: szukaj w plikach"],
            ["fd nazwa", "szybki find"],
            ["bat plik", "cat z kolorami i numerami"],
            ["jq '.a' · yq '.a'", "JSON · YAML/TOML"],
            ["http :3000/api", "httpie (albo xh)"],
            ["glow README.md", "markdown w terminalu"],
            ["rsync -avP źr/ cel/", "kopiowanie z postępem"],
            ["unar archiwum", "rozpakuj cokolwiek"],
            ["magick in.png -resize 50% out.png", "ImageMagick"],
        ] },
        { name: "TUI", items: [
            ["btop", "procesy, CPU, RAM, sieć"],
            ["numbat", "kalkulator z jednostkami"],
            ["calcurse", "kalendarz i zadania"],
            ["spotify_player", "Spotify w terminalu"],
            ["just", "uruchamiacz zadań (justfile)"],
            ["mitmproxy", "podgląd ruchu HTTP(S)"],
            ["sudo powertop", "zużycie energii"],
            ["db plik.sqlite", "lazysql: SQLite / MySQL"],
            ["tldr komenda", "krótkie przykłady (tealdeer)"],
        ] },
        // ── dev ──
        { name: "C/C++", items: [
            ["bear -- make", "compile_commands.json dla clangd"],
            ["clang-tidy src/*.c", "linter"],
            ["gdb ./app   (gdb -nx)", "debugger z pwndbg (bez)"],
            ["valgrind --leak-check=full", "wycieki pamięci"],
            ["strace -e openat ./app", "jakie pliki otwiera"],
            ["rr record ./app; rr replay", "debug wstecz: rc, rn"],
            ["perf record -g; hotspot", "profil CPU + flame graph"],
            ["heaptrack ./app", "kto alokuje pamięć"],
            ["nvim: F9 · F5 · F10/F11", "breakpoint · debuguj · krok (nvim-dap)"],
        ] },
        { name: "Rust", items: [
            ["bacon clippy", "błędy na żywo w tle"],
            ["cargo nextest run", "szybsze testy"],
            ["cargo clippy --fix", "lint + poprawki"],
            ["cargo expand", "rozwinięte makra"],
            ["cargo audit / deny check", "podatności, licencje"],
            ["cargo flamegraph", "profil → flamegraph.svg"],
            ["rust-gdb target/debug/app", "debugger"],
            ["cargo +nightly miri test", "UB w unsafe"],
            ["cargo build --timings", "co kompiluje się długo"],
        ] },
        { name: "Java", items: [
            ["jbang app.java", "plik .java jak skrypt"],
            ["jbang init -t cli app.java", "szablon CLI"],
            ["jshell", "REPL"],
            ["google-java-format -i *.java", "formatowanie"],
            ["jps", "PID-y procesów Javy"],
            ["asprof -d 30 -f fg.html PID", "flame graph JVM"],
            ["visualvm", "heap, wątki, GC na żywo"],
            ["archlinux-java status", "domyślna JDK"],
        ] },
        { name: "Docker", items: [
            ["lazydocker", "TUI: kontenery, logi"],
            ["dcu · dcd", "compose up -d · down"],
            ["dcl · dc", "compose logs -f · compose"],
            ["dps", "kontenery: nazwa, status, porty"],
            ["dprune", "usuń nieużywane (też wolumeny!)"],
            ["dive obraz:tag", "warstwy obrazu"],
            ["k9s", "TUI Kubernetesa"],
            ["kubectl logs -f POD", "logi na żywo"],
            ["act -j build", "GitHub Actions lokalnie"],
        ] },
        { name: "Sieć", items: [
            ["xh :3000/api", "GET localhost:3000"],
            ["xh POST :3000/u name=Jan a:=1", "JSON body"],
            ["hurl --test api.hurl", "testy HTTP"],
            ["oha -z 10s -c 50 URL", "test obciążeniowy"],
            ["gping 1.1.1.1", "ping jako wykres"],
            ["sudo trip host", "traceroute na żywo"],
            ["sudo bandwhich", "kto zżera sieć"],
        ] },
        { name: "Kod", items: [
            ["git dft", "diff składniowy (difftastic)"],
            ["watchexec -r -- cmd", "uruchom przy zmianie"],
            ["hyperfine 'a' 'b'", "benchmark komend"],
            ["shellcheck -x skrypt.sh", "linter basha"],
            ["tokei", "statystyki kodu"],
            ["fx dane.json", "przeglądarka JSON"],
            ["tldr narzędzie", "przykłady użycia"],
        ] },
    ]

    WheelHandler {
        onWheel: event => {
            const n = card.categories.length;
            card.category = (card.category + (event.angleDelta.y < 0 ? 1 : n - 1)) % n;
        }
    }

    ColumnLayout {
        spacing: 10
        width: 430

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: `${String.fromCodePoint(0xF0169)}  Ściąga dev`
                color: titleArea.containsMouse ? Colors.primary : Colors.text
                font { family: card.font; pixelSize: 14; weight: Font.Black }
                MouseArea {
                    id: titleArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.openUrlExternally("obsidian://open?path=" + encodeURIComponent(card.note))
                }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "kółko / klik: kategoria"
                color: Colors.textMuted
                opacity: 0.6
                font { family: card.font; pixelSize: 10; weight: Font.Bold }
            }
        }

        // zakładki kategorii
        Flow {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: card.categories
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool active: index === card.category
                    implicitWidth: label.implicitWidth + 16
                    implicitHeight: label.implicitHeight + 6
                    radius: 3
                    color: active ? Colors.primary : (chipArea.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh)
                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: modelData.name
                        color: active ? Colors.textOnPrimary : Colors.textMuted
                        font { family: card.font; pixelSize: 11; weight: Font.Bold }
                    }
                    MouseArea {
                        id: chipArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.category = index
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 14
            rowSpacing: 5

            Repeater {
                model: card.categories[card.category].items
                delegate: Text {
                    required property var modelData
                    required property int index
                    // komórki idą parami: komenda | opis
                    Layout.row: index
                    Layout.column: 0
                    text: modelData[0]
                    color: Colors.primary
                    font { family: card.font; pixelSize: 12; weight: Font.Bold }
                }
            }
            Repeater {
                model: card.categories[card.category].items
                delegate: Text {
                    required property var modelData
                    required property int index
                    Layout.row: index
                    Layout.column: 1
                    Layout.fillWidth: true
                    text: modelData[1]
                    elide: Text.ElideRight
                    color: Colors.textMuted
                    font { family: card.font; pixelSize: 11; weight: Font.Bold }
                }
            }
        }
    }
}
