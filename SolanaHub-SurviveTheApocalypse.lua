-- ============================================
-- SERVICES
-- ============================================
Players = game:GetService("Players")
UserInputService = game:GetService("UserInputService")
RunService = game:GetService("RunService")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
ReplicatedStorage = game:GetService("ReplicatedStorage")
Lighting = game:GetService("Lighting")
VirtualUser = game:GetService("VirtualUser")
TeleportService = game:GetService("TeleportService")
HttpService = game:GetService("HttpService")
TweenService = game:GetService("TweenService")
PathfindingService = game:GetService("PathfindingService")

-- ============================================
-- ANTI-CHEAT BYPASS SYSTEM Enhanced v2
-- ============================================
local function _initAntiCheat()
local _AC_NAMES = {
    "KnightmareAntiCheatClient",
    "SpeedAntiCheatAdjuster",
}
local _AC_NAME_SET = {}
for _, n in ipairs(_AC_NAMES) do _AC_NAME_SET[n] = true end

local function _isACName(name)
    if not name then return false end
    return _AC_NAME_SET[name] == true
end

local function _destroyIfAC(obj)
    if obj and obj.Parent and _isACName(obj.Name) then
        pcall(function()
            if obj:IsA("LocalScript") or obj:IsA("Script") then
                obj.Disabled = true
            elseif obj:IsA("ScreenGui") then
                obj.Enabled = false
            end
            obj:Destroy()
        end)
    end
end

local function _scanAC(container)
    if not container then return end
    _destroyIfAC(container)
    for _, d in ipairs(container:GetDescendants()) do
        _destroyIfAC(d)
    end
end

task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            local pg   = LocalPlayer:FindFirstChild("PlayerGui")
            local char = LocalPlayer.Character
            local ps   = LocalPlayer:FindFirstChild("PlayerScripts")
            if pg   then _scanAC(pg) end
            if char then _scanAC(char) end
            if ps   then _scanAC(ps) end
        end)
    end
end)

local function _hookCharACRemoval(char)
    if not char then return end
    char.DescendantAdded:Connect(function(c) task.defer(function() _scanAC(c) end) end)
    _scanAC(char)
end
LocalPlayer.CharacterAdded:Connect(_hookCharACRemoval)
if LocalPlayer.Character then _hookCharACRemoval(LocalPlayer.Character) end
local _pg = LocalPlayer:FindFirstChild("PlayerGui")
if _pg then
    _pg.DescendantAdded:Connect(function(c) task.defer(function() _scanAC(c) end) end)
    _scanAC(_pg)
end
local _ps = LocalPlayer:FindFirstChild("PlayerScripts")
if _ps then
    _ps.DescendantAdded:Connect(function(c) task.defer(function() _scanAC(c) end) end)
    _scanAC(_ps)
end
end
_initAntiCheat()

getgenv()._NX_acBypassConn = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local shActive = Toggles and Toggles.SpeedHack and Toggles.SpeedHack.Value
    if shActive then
        local desired = Options and Options.SpeedValue and Options.SpeedValue.Value or 25
        -- [Legit Speed Hack] Use attribute instead of forcing Humanoid.WalkSpeed
        char:SetAttribute("WalkSpeed", desired - 16)
    else
        if char:GetAttribute("WalkSpeed") then
            char:SetAttribute("WalkSpeed", nil)
        end
        if hum.WalkSpeed < 10 then hum.WalkSpeed = 16 end
    end

    local vel = hrp.AssemblyLinearVelocity
    if Vector3.new(vel.X, 0, vel.Z).Magnitude > 120 then
        hrp.AssemblyLinearVelocity = Vector3.new(0, vel.Y, 0)
    end
end)

-- ============================================
-- LOCALIZATION
-- ============================================
local _LANG = "EN"
pcall(function()
    local cfg = readfile("SolanaHub/survive-the-apocalypse/lang.json")
    if cfg then
        local ok, data = pcall(function() return HttpService:JSONDecode(cfg) end)
        if ok and data and data.lang then _LANG = data.lang end
    end
end)

_LANG_LABELS = {
    ["ID"]="Indonesia (ID)",["EN"]="English (EN)",["ES"]="Espanol (ES)",["PT"]="Portugues (PT)",
    ["MS"]="Melayu (MS)",["TL"]="Filipino (TL)",["DE"]="Deutsch (DE)",["FR"]="Francais (FR)",
    ["AR"]="Arabic (AR)",["VI"]="Tieng Viet (VI)",["TH"]="Thai (TH)",["TR"]="Turkce (TR)",
    ["JA"]="Japanese (JA)",["KO"]="Korean (KO)",["ZH"]="Chinese (ZH)",["RU"]="Russian (RU)",
}

_DICT = {
    tabVisuals   ={ID="Visual",EN="Visuals",ES="Visuales",PT="Visuais",MS="Visual",TL="Visual",DE="Visuals",FR="Visuels",AR="Visuals",VI="Hinh anh",TH="Phap",TR="Gorseller",JA="Bijuaru",KO="Bijeol",ZH="Shijue",RU="Vizual"},
    tabPlayer    ={ID="Pemain",EN="Player",ES="Jugador",PT="Jogador",MS="Pemain",TL="Manlalaro",DE="Spieler",FR="Joueur",AR="Player",VI="Nguoi choi",TH="Phuen",TR="Oyuncu",JA="Pureiya",KO="Peulleieo",ZH="Wanjia",RU="Igrok"},
    tabCombat    ={ID="Tempur",EN="Combat",ES="Combate",PT="Combate",MS="Pertempuran",TL="Labanan",DE="Kampf",FR="Combat",AR="Combat",VI="Chien dau",TH="Kanthosuu",TR="Savas",JA="Sento",KO="Jeontu",ZH="Zhandou",RU="Boy"},
    tabExploits  ={ID="Auto Play",EN="Auto Play",ES="Auto Play",PT="Auto Play",MS="Auto Play",TL="Auto Play",DE="Auto Play",FR="Auto Play",AR="Auto Play",VI="Auto Play",TH="Auto Play",TR="Auto Play",JA="Auto Play",KO="Auto Play",ZH="Auto Play",RU="Auto Play"},
    tabMisc      ={ID="Lainnya",EN="Misc",ES="Varios",PT="Misc",MS="Lain-lain",TL="Iba pa",DE="Diverses",FR="Divers",AR="Misc",VI="Khac",TH="Uen",TR="Cesitli",JA="Sonota",KO="Gita",ZH="Qita",RU="Prochee"},
    tabUISettings={ID="Pengaturan UI",EN="UI Settings",ES="Ajustes UI",PT="Config UI",MS="Tetapan UI",TL="UI Settings",DE="UI Einst.",FR="Param. UI",AR="UI Settings",VI="Cai dat UI",TH="UI",TR="UI Ayarlari",JA="UI Settei",KO="UI Seoljeong",ZH="UI Shezhi",RU="Nastrojki UI"},
    menu={ID="Menu",EN="Menu",ES="Menu",PT="Menu",MS="Menu",TL="Menu",DE="Menu",FR="Menu",AR="Menu",VI="Menu",TH="Menu",TR="Menu",JA="Menu",KO="Menu",ZH="Menu",RU="Menyu"},
    language={ID="Bahasa",EN="Language",ES="Idioma",PT="Idioma",MS="Bahasa",TL="Wika",DE="Sprache",FR="Langue",AR="Language",VI="Ngon ngu",TH="Language",TR="Dil",JA="Language",KO="Language",ZH="Language",RU="Yazyk"},
    langApply={ID="berlaku setelah execute ulang",EN="applies after Solt script execute",ES="se aplica al ejecutar de nuevo",PT="aplica apos reexecutar",MS="digunakan selepas execute semula",TL="gagana pagkatapos i-execute ulit",DE="gilt nach erneutem Ausfuehren",FR="s'applique apres reexecution",AR="applies after Solt script execute",VI="ap dung sau khi chay lai script",TH="applies after Solt script execute",TR="script yeniden calistirilinca uygulanir",JA="applies after Solt script execute",KO="applies after Solt script execute",ZH="applies after Solt script execute",RU="primenitsya posle povtornogo zapuska"},
}

_UI_TEXT = {
    ["Visuals"] = _DICT.tabVisuals, ["Player"] = _DICT.tabPlayer,
    ["Combat"] = _DICT.tabCombat, ["Auto Play"] = _DICT.tabExploits,
    ["Exploits"] = _DICT.tabExploits, ["Misc"] = _DICT.tabMisc,
    ["UI Settings"] = _DICT.tabUISettings,
    ["Menu"] = _DICT.menu,
    ["Language"] = _DICT.language,
    ["Open Keybind Menu"] = { ID = "Buka Menu Keybind" },
    ["Custom Cursor"] = { ID = "Cursor Kustom" },
    ["Notification Side"] = { ID = "Sisi Notifikasi" },
    ["DPI Scale"] = { ID = "Skala DPI" },
    ["Corner Radius"] = { ID = "Radius Sudut" },
    ["Menu bind"] = { ID = "Tombol Menu" },
    ["Menu keybind"] = { ID = "Keybind Menu" },
}

local function _addUIText(en,id,es,pt,ms,tl,de,fr,ar,vi,th,tr,ja,ko,zh,ru)
    _UI_TEXT[en] = {ID=id,EN=en,ES=es,PT=pt,MS=ms,TL=tl,DE=de,FR=fr,AR=ar,VI=vi,TH=th,TR=tr,JA=ja,KO=ko,ZH=zh,RU=ru}
end

_addUIText("Open Keybind Menu","Buka Menu Keybind","Abrir menu de teclas","Abrir menu de atalhos","Buka menu kekunci","Buksan keybind menu","Tastenmenue oeffnen","Ouvrir menu raccourcis","Fath qaimat al-mafatih","Mo menu phim tat","Poet menu keybind","Kisayol menusu ac","Ki baindo menu wo hiraku","Kibain menu yeolgi","Dakai anjian caidan","Otkryt menyu klavish")
_addUIText("Custom Cursor","Cursor Kustom","Cursor personalizado","Cursor personalizado","Kursor khas","Custom cursor","Benutzer-Cursor","Curseur personnalise","Mushir mukhassas","Con tro tuy chinh","Cursor phiset","Ozel imlec","Kasutamu kasoru","Custom keoseo","Zidingyi guangbiao","Polzovatelskiy kursor")
_addUIText("Notification Side","Sisi Notifikasi","Lado de notificacion","Lado da notificacao","Sisi notifikasi","Gilid ng notipikasyon","Benachrichtigungsseite","Cote notification","Janib al-ishaar","Phia thong bao","Dan khong chaeng","Bildirim tarafi","Tsuchi no gawa","Allim wich","Tongzhi weizhi","Storona uvedomleniy")
_addUIText("DPI Scale","Skala DPI","Escala DPI","Escala DPI","Skala DPI","Sukat DPI","DPI Skalierung","Echelle DPI","Miqyas DPI","Ti le DPI","Khanaat DPI","DPI olcegi","DPI sukairu","DPI seukeil","DPI suofang","Masshtab DPI")
_addUIText("Corner Radius","Radius Sudut","Radio de esquina","Raio do canto","Jejari bucu","Kurbada ng sulok","Eckenradius","Rayon des coins","Nisf qutr al-zawaya","Ban kinh goc","Radius mum","Kose yaricapi","Kado hankei","Moseori bandgyeong","Yuanjiao banjing","Radius uglov")
_addUIText("Menu bind","Tombol Menu","Tecla del menu","Tecla do menu","Butang menu","Menu key","Menue-Taste","Touche menu","Miftah al-menu","Phim menu","Pum menu","Menu tusu","Menu kii","Menu ki","Caidan anjian","Klavisha menyu")
_addUIText("Menu keybind","Keybind Menu","Atajo del menu","Atalho do menu","Keybind menu","Menu keybind","Menue-Tastenbindung","Raccourci menu","Rabt miftah al-menu","Phim tat menu","Keybind menu","Menu kisayolu","Menu ki baindo","Menu kibain","Caidan kuaijiejian","Privyazka menyu")

_addUIText("ESP Settings","Pengaturan ESP","Ajustes ESP","Config ESP","Tetapan ESP","ESP settings","ESP Einstellungen","Parametres ESP","Iidadat ESP","Cai dat ESP","Tang kha ESP","ESP ayarlari","ESP settei","ESP seoljeong","ESP shezhi","Nastrojki ESP")
_addUIText("Max Distance","Jarak Maks","Distancia maxima","Distancia maxima","Jarak maksimum","Max distansya","Max Entfernung","Distance max","Aqsa masafa","Khoang cach toi da","Raya thang mak sut","Maks mesafe","Saidai kyori","Choedae geori","Zuida juli","Maks distantsiya")
_addUIText("Show Names","Tampilkan Nama","Mostrar nombres","Mostrar nomes","Papar nama","Ipakita pangalan","Namen zeigen","Afficher noms","Izhar al-asma","Hien ten","Sa-daeng chue","Isimleri goster","Namae hyoji","Ireum pyosi","Xianshi mingzi","Pokazat imena")
_addUIText("Show Distance","Tampilkan Jarak","Mostrar distancia","Mostrar distancia","Papar jarak","Ipakita distansya","Distanz zeigen","Afficher distance","Izhar al-masafa","Hien khoang cach","Sa-daeng raya","Mesafeyi goster","Kyori hyoji","Geori pyosi","Xianshi juli","Pokazat distantsiyu")
_addUIText("Text Size","Ukuran Teks","Tamano de texto","Tamanho do texto","Saiz teks","Laki ng text","Textgroesse","Taille texte","Hajm al-nass","Co chu","Khanat tuaakson","Metin boyutu","Tekisuto saizu","Tekseuteu keugi","Wenzi daxiao","Razmer teksta")
_addUIText("Fill Transparency","Transparansi Isi","Transparencia de relleno","Transparencia do preenchimento","Ketelusan isi","Transparency ng fill","Fuell-Transparenz","Transparence remplissage","Shafafiyat al-milØ¡","Do trong suot phan to","Khwam sai fill","Dolgu seffafligi","Nuri tomen","Chaeum tumyeongdo","Tianchong toumingdu","Prozrachnost zalivki")
_addUIText("Outline Transparency","Transparansi Garis","Transparencia del borde","Transparencia do contorno","Ketelusan garis","Transparency ng outline","Umriss-Transparenz","Transparence contour","Shafafiyat al-itar","Do trong suot vien","Khwam sai khop","Cizgi seffafligi","Waku tomen","Oegwak tumyeongdo","Lunkuo toumingdu","Prozrachnost kontura")
_addUIText("Boss / Brute Alert","Peringatan Boss / Brute","Alerta Boss / Brute","Alerta Boss / Brute","Amaran Boss / Brute","Alert Boss / Brute","Boss/Brute Alarm","Alerte Boss / Brute","Tanbih Boss / Brute","Canh bao Boss / Brute","Chaeng teuan Boss / Brute","Boss / Brute uyarisi","Boss / Brute keikoku","Boss / Brute gyeonggo","Boss / Brute jingbao","Signal Boss / Brute")
_addUIText("Mob ESP","ESP Mob","ESP mobs","ESP mobs","ESP mob","Mob ESP","Mob ESP","ESP mobs","ESP mob","ESP quai","Mob ESP","Mob ESP","Mob ESP","Mob ESP","Mob ESP","ESP mobov")
_addUIText("Chams","Chams","Chams","Chams","Chams","Chams","Chams","Chams","Chams","Chams","Chams","Chams","Chams","Chams","Chams","Chams")
_addUIText("Player ESP","ESP Pemain","ESP jugador","ESP jogador","ESP pemain","Player ESP","Spieler ESP","ESP joueur","ESP player","ESP nguoi choi","Player ESP","Oyuncu ESP","Player ESP","Player ESP","Wanjia ESP","ESP igroka")
_addUIText("Show Health","Tampilkan HP","Mostrar vida","Mostrar vida","Papar HP","Ipakita HP","HP zeigen","Afficher vie","Izhar al-sihha","Hien HP","Sa-daeng HP","Can goster","HP hyoji","HP pyosi","Xianshi xueliang","Pokazat HP")
_addUIText("Item ESP","ESP Item","ESP objetos","ESP itens","ESP item","Item ESP","Item ESP","ESP objets","ESP item","ESP vat pham","Item ESP","Esya ESP","Item ESP","Item ESP","Wupin ESP","ESP predmetov")
_addUIText("Chams (All Categories)","Chams Semua Kategori","Chams todas categorias","Chams todas categorias","Chams semua kategori","Chams lahat kategorya","Chams alle Kategorien","Chams toutes categories","Chams kull al-fiat","Chams moi muc","Chams thuk muat","Chams tum kategoriler","Chams subete","Chams modeun bunryu","Chams suoyou leibie","Chams vse kategorii")
_addUIText("Structures","Struktur","Estructuras","Estruturas","Struktur","Structures","Strukturen","Structures","Hayakil","Cong trinh","Sing sang","Yapilar","Kozo","Gujo","Jiegou","Struktury")
_addUIText("Structure ESP","ESP Struktur","ESP estructuras","ESP estruturas","ESP struktur","Structure ESP","Struktur ESP","ESP structures","ESP hayakil","ESP cong trinh","Structure ESP","Yapi ESP","Structure ESP","Structure ESP","Jiegou ESP","ESP struktur")

_addUIText("Movement","Gerakan","Movimiento","Movimento","Pergerakan","Galaw","Bewegung","Mouvement","Haraka","Di chuyen","Kan khluean wai","Hareket","Ido","Idong","Yidong","Dvizhenie")
_addUIText("Speed Hack","Speed Hack","Hack velocidad","Hack velocidade","Speed hack","Speed hack","Speed Hack","Speed hack","Speed hack","Hack toc do","Speed hack","Hiz hack","Speed hack","Speed hack","Suduhack","Speed hack")
_addUIText("Walk Speed","Kecepatan Jalan","Velocidad caminar","Velocidade andar","Kelajuan jalan","Bilis lakad","Laufgeschwindigkeit","Vitesse marche","Surat al-mashy","Toc do di bo","Khwam reo doen","Yurume hizi","Aruki sokudo","Georeum sokdo","Buxing sudu","Skorost hody")
_addUIText("Inf Jump","Lompat Tak Terbatas","Salto infinito","Pulo infinito","Lompat tanpa had","Infinite jump","Unendlich springen","Saut infini","Qafz la nihai","Nhay vo han","Jump mai chamkat","Sonsuz ziplama","Mugen janpu","Muhanjeompeu","Wuxian tiao","Beskonechnyy pryzhok")
_addUIText("NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip","NoClip")
_addUIText("Fly","Terbang","Volar","Voar","Terbang","Lumipad","Fliegen","Voler","Tayaran","Bay","Bin","Uc","Tobu","Nalgi","Feixing","Letat")
_addUIText("Fly Speed","Kecepatan Terbang","Velocidad vuelo","Velocidade voo","Kelajuan terbang","Bilis lipad","Fluggeschwindigkeit","Vitesse vol","Surat al-tayaran","Toc do bay","Khwam reo bin","Ucus hizi","Hiko sokudo","Bihaeng sokdo","Feixing sudu","Skorost poleta")
_addUIText("Auto Sprint","Sprint Otomatis","Sprint auto","Sprint automatico","Sprint auto","Auto sprint","Auto Sprint","Sprint auto","Sprint auto","Tu dong chay nhanh","Auto sprint","Oto kosu","Auto sprint","Auto sprint","Zidong chongci","Avto sprint")
_addUIText("Bunny Hop","Bunny Hop","Bunny hop","Bunny hop","Bunny hop","Bunny hop","Bunny Hop","Bunny hop","Bunny hop","Bunny hop","Bunny hop","Bunny hop","Bunny hop","Bunny hop","Bunny hop","Bunny hop")

_addUIText("Kill Aura","Kill Aura","Aura de muerte","Aura de morte","Kill aura","Kill aura","Kill Aura","Aura kill","Kill aura","Kill aura","Kill aura","Kill aura","Kill aura","Kill aura","Kill aura","Kill aura")
_addUIText("Target Priority","Prioritas Target","Prioridad objetivo","Prioridade alvo","Keutamaan sasaran","Priority target","Zielprioritaet","Priorite cible","Awlawiyat hadaf","Uu tien muc tieu","Lam dapao mai","Hedef onceligi","Target yusen","Target useon","Mubiao youxian","Prioritet tseli")
_addUIText("Show Target Indicator","Tampilkan Indikator Target","Mostrar indicador objetivo","Mostrar indicador alvo","Papar penanda sasaran","Ipakita indicator target","Zielanzeige zeigen","Afficher indicateur cible","Izhar muashir hadaf","Hien chi bao muc tieu","Sa-daeng tua chi pao mai","Hedef gostergesini goster","Target shihyo hyoji","Target pyosigi pyosi","Xianshi mubiao zhishi","Pokazat indikator tseli")
_addUIText("Extended Range (+2 studs)","Jarak Tambahan (+2 studs)","Rango extendido (+2 studs)","Alcance estendido (+2 studs)","Jarak lanjut (+2 studs)","Extended range (+2 studs)","Erweiterte Reichweite (+2 studs)","Portee etendue (+2 studs)","Mada mumtad (+2 studs)","Tam xa them (+2 studs)","Raya phoem (+2 studs)","Genis menzil (+2 studs)","Kakucho hani (+2 studs)","Hwaksang beomwi (+2 studs)","Kuozhan fanwei (+2 studs)","Rasshirennaya dalnost (+2 studs)")
_addUIText("Base Range","Jarak Dasar","Rango base","Alcance base","Jarak asas","Base range","Basisreichweite","Portee base","Mada asasi","Tam co ban","Raya phuen than","Temel menzil","Kihon hani","Gibon beomwi","Jichu fanwei","Bazovaya dalnost")
_addUIText("Swing Delay (s)","Delay Ayun (d)","Retraso golpe (s)","Atraso golpe (s)","Lewat hayun (s)","Delay palo (s)","Schlagverzoegerung (s)","Delai coup (s)","Taakhir darb (s)","Tre danh (s)","Delay ti (s)","Sallama gecikmesi (s)","Swing chien (s)","Swing jeyeon (s)","Huiji yanchi (s)","Zaderzhka udara (s)")
_addUIText("Weapon Speeds Info:","Info Kecepatan Senjata:","Info velocidades arma:","Info velocidades arma:","Info kelajuan senjata:","Info bilis sandata:","Waffen-Speed Info:","Info vitesses armes:","Maelumat surat silah:","Thong tin toc do vu khi:","Khormun khwam reo awut:","Silah hiz bilgisi:","Buki sokudo joho:","Mugi sokdo jeongbo:","Wuqisudu xinxi:","Info skorosti oruzhiya:")

_addUIText("Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot","Aimbot")
_addUIText("Target Mode","Mode Target","Modo objetivo","Modo alvo","Mod sasaran","Target mode","Zielmodus","Mode cible","Wad hadaf","Che do muc tieu","Mode pao mai","Hedef modu","Target modo","Target modeu","Mubiao moshi","Rezhim tseli")
_addUIText("Aim Part","Bagian Aim","Parte apuntar","Parte mira","Bahagian aim","Aim part","Zielteil","Partie visee","Juz tasdid","Phan ngam","Suan leà¹‡à¸‡","Nisan parcasi","Aim bubun","Aim bubun","Miaozhun buwei","Chast navodki")
_addUIText("Max Range","Jarak Maks","Rango maximo","Alcance maximo","Jarak maksimum","Max range","Max Reichweite","Portee max","Aqsa mada","Tam toi da","Raya mak sut","Maks menzil","Saidai hani","Choedae beomwi","Zuida fanwei","Maks dalnost")
_addUIText("FOV Radius","Radius FOV","Radio FOV","Raio FOV","Jejari FOV","FOV radius","FOV Radius","Rayon FOV","Nisf qutr FOV","Ban kinh FOV","Radius FOV","FOV yaricapi","FOV hankei","FOV bandgyeong","FOV banjing","Radius FOV")
_addUIText("Smoothness","Kehalusan","Suavidad","Suavidade","Kelancaran","Smoothness","Glaettung","Lissage","Nauuma","Do muot","Khwam nuan","Yumusaklik","Namerakasa","Budeureoum","Pinghua","Plavnost")
_addUIText("Velocity Prediction","Prediksi Kecepatan","Prediccion velocidad","Previsao velocidade","Ramalan halaju","Velocity prediction","Geschwindigkeitsvorhersage","Prediction vitesse","Tawaqqu surat","Du doan van toc","Khad kan khwam reo","Hiz tahmini","Sokudo yosoku","Sokdo yecheuk","Sudu yuce","Prognoz skorosti")
_addUIText("Prediction Amount","Jumlah Prediksi","Cantidad prediccion","Quantidade previsao","Jumlah ramalan","Prediction amount","Vorhersagewert","Quantite prediction","Miqdar tawaqqu","Luong du doan","Jamnuan khad kan","Tahmin miktari","Yosoku ryo","Yecheuk yang","Yuce liang","Sila prognoza")
_addUIText("FOV Circle","Lingkaran FOV","Circulo FOV","Circulo FOV","Bulatan FOV","FOV circle","FOV Kreis","Cercle FOV","Daira FOV","Vong FOV","Wong FOV","FOV dairesi","FOV en","FOV won","FOV yuan","Krug FOV")
_addUIText("Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox y Anti-Aim","Hitbox e Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim","Hitbox & Anti-Aim")
_addUIText("Expand Zombie Hitboxes","Perbesar Hitbox Zombie","Expandir hitboxes zombie","Expandir hitboxes zombie","Besarkan hitbox zombie","Palakihin zombie hitbox","Zombie-Hitbox vergroessern","Agrandir hitbox zombie","Tawsie hitbox zombie","Mo rong hitbox zombie","Khà¸¢à¸²à¸¢ hitbox zombie","Zombi hitbox genislet","Zombie hitbox kakudai","Zombie hitbox hwakjang","Kuoda jiangshi hitbox","Uvelichit hitbox zombi")
_addUIText("Hitbox Size","Ukuran Hitbox","Tamano hitbox","Tamanho hitbox","Saiz hitbox","Laki hitbox","Hitbox-Groesse","Taille hitbox","Hajm hitbox","Co hitbox","Khanat hitbox","Hitbox boyutu","Hitbox saizu","Hitbox keugi","Hitbox daxiao","Razmer hitbox")
_addUIText("Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)","Anti-Aim (HvH Spinbot)")

_addUIText("Auto Farm","Auto Farm","Auto farm","Auto farm","Auto farm","Auto farm","Auto Farm","Auto farm","Auto farm","Auto farm","Auto farm","Auto farm","Auto farm","Auto farm","Auto farm","Avto farm")
_addUIText("Auto Farm Zombies","Auto Farm Zombie","Auto farm zombies","Auto farm zombies","Auto farm zombie","Auto farm zombies","Auto Farm Zombies","Auto farm zombies","Auto farm zombies","Auto farm zombie","Auto farm zombies","Auto farm zombies","Auto farm zombies","Auto farm zombies","Auto farm jiangshi","Avto farm zombi")
_addUIText("Auto Farm Items","Auto Farm Item","Auto farm objetos","Auto farm itens","Auto farm item","Auto farm items","Auto Farm Items","Auto farm objets","Auto farm items","Auto farm vat pham","Auto farm item","Auto farm esya","Auto farm items","Auto farm items","Auto farm wupin","Avto farm predmetov")
_addUIText("Auto Return to Generator (Backpack Full)","Auto Kembali ke Generator (Tas Penuh)","Auto volver al generador (mochila llena)","Auto voltar ao gerador (mochila cheia)","Auto kembali ke generator (beg penuh)","Auto balik generator (bag full)","Auto zurueck zum Generator (Rucksack voll)","Retour auto generateur (sac plein)","Awda auto lil-generator (haqiba mumtalia)","Tu dong ve may phat (tui day)","Auto klap pai generator (krapao tem)","Generatora otomatik don (canta dolu)","Generator ni auto modoru (bag full)","Generator auto bogui (bag full)","Zidong fanhui fadianji (beibao man)","Avto vozvrat k generatoru (ryukzak polon)")
_addUIText("Hover Height","Tinggi Hover","Altura hover","Altura hover","Tinggi hover","Taas hover","Hover-Hoehe","Hauteur hover","Irtifa hover","Do cao hover","Khwam sung hover","Hover yuksekligi","Hover takasa","Hover nopi","Hover gaodu","Vysota hover")
_addUIText("Farm Move Speed","Kecepatan Gerak Farm","Velocidad movimiento farm","Velocidade movimento farm","Kelajuan gerak farm","Bilis galaw farm","Farm Bewegungstempo","Vitesse deplacement farm","Surat haraka farm","Toc do di chuyen farm","Khwam reo khluean farm","Farm hareket hizi","Farm ido sokudo","Farm idong sokdo","Farm yidong sudu","Skorost dvizheniya farma")
_addUIText("Auto Pickup","Auto Pickup","Auto recoger","Auto coletar","Auto pickup","Auto pickup","Auto Pickup","Ramassage auto","Auto iltiqat","Tu dong nhat","Auto kep","Oto al","Auto pickup","Auto pickup","Zidong shiqu","Avto podbor")
_addUIText("All Items","Semua Item","Todos objetos","Todos itens","Semua item","Lahat items","Alle Items","Tous objets","Kull items","Tat ca vat pham","Item thang mot","Tum esyalar","Subete no item","Modeun item","Suoyou wupin","Vse predmety")
_addUIText("FE Methods (combine to test)","Metode FE (gabungkan untuk tes)","Metodos FE (combinar para probar)","Metodos FE (combine para testar)","Kaedah FE (gabung untuk test)","FE methods (pagsamahin pang test)","FE Methoden (kombinieren zum Test)","Methodes FE (combiner pour test)","Turuq FE (imzaj lil-test)","Phuong phap FE (ket hop de thu)","Withi FE (phsom phuea thot sop)","FE yontemleri (test icin birlestir)","FE hoho (test de kumiawase)","FE bangbeop (test yong gyeolhap)","FE fangfa (zuhe ceshi)","Metody FE (kombinirovat dlya testa)")
_addUIText("Method A: Remote","Metode A: Remote","Metodo A: Remote","Metodo A: Remote","Kaedah A: Remote","Method A: Remote","Methode A: Remote","Methode A: Remote","Tariqa A: Remote","Cach A: Remote","Withi A: Remote","Yontem A: Remote","Hoho A: Remote","Bangbeop A: Remote","Fangfa A: Remote","Metod A: Remote")
_addUIText("Method B: Touch","Metode B: Touch","Metodo B: Touch","Metodo B: Touch","Kaedah B: Touch","Method B: Touch","Methode B: Touch","Methode B: Touch","Tariqa B: Touch","Cach B: Touch","Withi B: Touch","Yontem B: Touch","Hoho B: Touch","Bangbeop B: Touch","Fangfa B: Touch","Metod B: Touch")
_addUIText("Method C: Prompt","Metode C: Prompt","Metodo C: Prompt","Metodo C: Prompt","Kaedah C: Prompt","Method C: Prompt","Methode C: Prompt","Methode C: Prompt","Tariqa C: Prompt","Cach C: Prompt","Withi C: Prompt","Yontem C: Prompt","Hoho C: Prompt","Bangbeop C: Prompt","Fangfa C: Prompt","Metod C: Prompt")
_addUIText("Item Whitelist (when All Items is off)","Whitelist Item (saat Semua Item mati)","Whitelist objetos (cuando Todos esta off)","Whitelist itens (quando Todos esta off)","Whitelist item (bila Semua item off)","Item whitelist (kapag All Items off)","Item Whitelist (wenn Alle Items aus)","Whitelist objets (quand Tous est off)","Whitelist items (indama kull items off)","Whitelist vat pham (khi tat ca tat)","Whitelist item (muea All Items off)","Esya beyaz liste (Tum kapali iken)","Item whitelist (subete off no toki)","Item whitelist (All Items off)","Wupin baimingdan (suoyou off)","Belyy spisok predmetov (kogda vse off)")
_addUIText("Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Whitelist","Baimingdan","Belyy spisok")
_addUIText("Repair Aura","Repair Aura","Aura reparar","Aura reparar","Repair aura","Repair aura","Repair Aura","Aura reparation","Repair aura","Repair aura","Repair aura","Repair aura","Repair aura","Repair aura","Repair aura","Repair aura")
_addUIText("Requires: Repair Hammer equipped","Butuh: Repair Hammer dipakai","Requiere: martillo equipado","Requer: martelo equipado","Perlu: Repair Hammer dipakai","Kailangan: Repair Hammer equipped","Benoetigt: Repair Hammer ausgeruestet","Requis: Repair Hammer equipe","Yat talab: Repair Hammer","Can trang bi Repair Hammer","Tong sai Repair Hammer","Gerekli: Repair Hammer takili","Repair Hammer sobi hitsuyo","Repair Hammer jangchak pilsu","Xuyao zhuangbei Repair Hammer","Nuzhen Repair Hammer v rukah")
_addUIText("Auto Use & Heal","Auto Use & Heal","Auto usar y curar","Auto usar e curar","Auto guna & heal","Auto use & heal","Auto Nutzen & Heilen","Auto utiliser & heal","Auto use & heal","Tu dong dung & hoi mau","Auto use & heal","Oto kullan & iyiles","Auto use & heal","Auto use & heal","Zidong shiyong & zhiliao","Avto ispolzovat i lechit")
_addUIText("Auto Use / Heal","Auto Use / Heal","Auto usar / curar","Auto usar / curar","Auto guna / heal","Auto use / heal","Auto Nutzen / Heilen","Auto utiliser / heal","Auto use / heal","Tu dong dung / hoi mau","Auto use / heal","Oto kullan / iyiles","Auto use / heal","Auto use / heal","Zidong shiyong / zhiliao","Avto ispolzovat / lechit")
_addUIText("Auto Use Radius","Radius Auto Use","Radio auto usar","Raio auto usar","Jejari auto guna","Auto use radius","Auto Use Radius","Rayon auto use","Nisf qutr auto use","Ban kinh auto use","Radius auto use","Auto use yaricapi","Auto use hankei","Auto use bandgyeong","Auto use banjing","Radius avto ispolzovaniya")
_addUIText("Smart Auto Heal","Smart Auto Heal","Auto curar inteligente","Auto curar inteligente","Smart auto heal","Smart auto heal","Smart Auto Heal","Auto heal intelligent","Smart auto heal","Tu dong hoi mau thong minh","Smart auto heal","Akilli oto heal","Smart auto heal","Smart auto heal","Zhineng auto heal","Umnyy auto heal")
_addUIText("Auto Eat","Auto Makan","Auto comer","Auto comer","Auto makan","Auto kain","Auto Essen","Auto manger","Auto eat","Tu dong an","Auto kin","Oto ye","Auto eat","Auto eat","Zidong chi","Avto est")
_addUIText("Hunger Threshold (%)","Batas Lapar (%)","Umbral hambre (%)","Limite fome (%)","Ambang lapar (%)","Hunger threshold (%)","Hunger-Schwelle (%)","Seuil faim (%)","Hadd al-ju (%)","Nguong doi (%)","Kha hunger (%)","Aclik esigi (%)","Hunger shikii (%)","Hunger gyesan (%)","Ji e yuzhi (%)","Porog goloda (%)")
_addUIText("Heal Threshold (%)","Batas Heal (%)","Umbral curar (%)","Limite cura (%)","Ambang heal (%)","Heal threshold (%)","Heal-Schwelle (%)","Seuil heal (%)","Hadd heal (%)","Nguong hoi mau (%)","Kha heal (%)","Heal esigi (%)","Heal shikii (%)","Heal gyesan (%)","Zhiliao yuzhi (%)","Porog lecheniya (%)")
_addUIText("Item Filter","Filter Item","Filtro objetos","Filtro itens","Filter item","Item filter","Item Filter","Filtre objets","Filter items","Loc vat pham","Filter item","Esya filtresi","Item filter","Item filter","Wupin guolv","Filtr predmetov")
_addUIText("Auto Trash","Auto Trash","Auto basura","Auto lixo","Auto trash","Auto trash","Auto Trash","Auto trash","Auto trash","Auto trash","Auto trash","Auto trash","Auto trash","Auto trash","Zidong diuqi","Avto musor")
_addUIText("Auto Trash / Drop Item","Auto Trash / Drop Item","Auto tirar / soltar objeto","Auto lixo / dropar item","Auto trash / drop item","Auto trash / drop item","Auto Trash / Item droppen","Auto trash / drop objet","Auto trash / drop item","Tu dong bo / tha vat pham","Auto trash / drop item","Oto cop / esya at","Auto trash / drop item","Auto trash / drop item","Zidong diuqi / reng wupin","Avto musor / vybrosit predmet")
_addUIText("Trash Filter","Filter Trash","Filtro basura","Filtro lixo","Filter trash","Trash filter","Trash Filter","Filtre trash","Filter trash","Loc trash","Filter trash","Cop filtresi","Trash filter","Trash filter","Diuqi guolv","Filtr musora")

_addUIText("Utilities","Utilitas","Utilidades","Utilidades","Utiliti","Utilities","Utilities","Utilitaires","Adawat","Tien ich","Utilities","Araclar","Utilities","Utilities","Gongju","Utiliti")
_addUIText("Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK","Anti-AFK")
_addUIText("Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright","Fullbright")
_addUIText("Remove Fog","Hapus Kabut","Quitar niebla","Remover nevoa","Buang kabus","Alisin fog","Nebel entfernen","Retirer brouillard","Izalat al-dabab","Xoa suong mu","Lop mok","Sisi kaldir","Kiri sakujo","Angae jegeo","Quchu wu","Ubrat tuman")
_addUIText("Potato Mode (Clean Map)","Mode Kentang (Bersihkan Map)","Modo patata (limpiar mapa)","Modo batata (limpar mapa)","Mod kentang (bersih map)","Potato mode (linis mapa)","Potato Mode (Map reinigen)","Mode potato (nettoyer map)","Potato mode (tanzif map)","Che do potato (don map)","Potato mode (tham khwam sa-at map)","Patates modu (harita temizle)","Potato mode (map soji)","Potato mode (map cheongso)","Tudou moshi (qingli ditu)","Potato rezhim (ochistit kartu)")
_addUIText("FPS Cap","Batas FPS","Limite FPS","Limite FPS","Had FPS","FPS cap","FPS Limit","Limite FPS","Hadd FPS","Gioi han FPS","Jamkat FPS","FPS limiti","FPS jougen","FPS jehan","FPS xianzhi","Limit FPS")
_addUIText("Unlock FPS","Unlock FPS","Desbloquear FPS","Desbloquear FPS","Buka FPS","Unlock FPS","FPS entsperren","Debloquer FPS","Fath FPS","Mo khoa FPS","Unlock FPS","FPS kilidini ac","FPS unlock","FPS unlock","Jiesuo FPS","Razblok FPS")
_addUIText("Server Tools","Alat Server","Herramientas servidor","Ferramentas servidor","Alat server","Server tools","Server Tools","Outils serveur","Adawat server","Cong cu server","Khrueang mue server","Sunucu araclari","Server tools","Server tools","Fuwuqi gongju","Instrumenty servera")
_addUIText("Server Hop","Pindah Server","Cambiar servidor","Trocar servidor","Tukar server","Server hop","Server wechseln","Changer serveur","Taghyir server","Doi server","Yai server","Sunucu degistir","Server ido","Server idong","Tiaofu fuwuqi","Smena servera")
_addUIText("Rejoin Server","Masuk Ulang Server","Reentrar servidor","Reentrar servidor","Masuk semula server","Rejoin server","Server neu beitreten","Rejoindre serveur","Iadat dukhul server","Vao lai server","Khao server mai","Sunucuya yeniden gir","Server ni hairinaosu","Server jaejeopsok","Chongxin jinru fuwuqi","Perezayti na server")
_addUIText("Current Job ID:","Job ID Saat Ini:","Job ID actual:","Job ID atual:","Job ID semasa:","Current Job ID:","Aktuelle Job ID:","Job ID actuel:","Job ID hali:","Job ID hien tai:","Job ID patchuban:","Guncel Job ID:","Genzai Job ID:","Hyeonjae Job ID:","Dangqian Job ID:","Tekushchiy Job ID:")
_addUIText("Anti Prompt","Anti Prompt","Anti prompt","Anti prompt","Anti prompt","Anti prompt","Anti Prompt","Anti prompt","Anti prompt","Anti prompt","Anti prompt","Anti prompt","Anti prompt","Anti prompt","Anti prompt","Anti prompt")
_addUIText("Anti Prompt V2","Anti Prompt V2","Anti prompt V2","Anti prompt V2","Anti prompt V2","Anti prompt V2","Anti Prompt V2","Anti prompt V2","Anti prompt V2","Anti prompt V2","Anti prompt V2","Anti prompt V2","Anti prompt V2","Anti prompt V2","Anti prompt V2","Anti prompt V2")
_addUIText("Prompt Radius","Radius Prompt","Radio de prompt","Raio de prompt","Jejari prompt","Radius prompt","Prompt-Radius","Rayon prompt","Nisf qutr al-prompt","Ban kinh prompt","Ratsami prompt","Prompt yaricapi","Prompt hankei","Prompt banji","Prompt banjing","Radius prompta")
_addUIText("Player Utilities","Utilitas Pemain","Utilidades jugador","Utilidades jogador","Utiliti pemain","Player utilities","Spieler Utilities","Utilitaires joueur","Adawat player","Tien ich nguoi choi","Utilities phu len","Oyuncu araclari","Player utilities","Player utilities","Wanjia gongju","Utiliti igroka")
_addUIText("Anti Ragdoll","Anti Ragdoll","Anti ragdoll","Anti ragdoll","Anti ragdoll","Anti ragdoll","Anti Ragdoll","Anti ragdoll","Anti ragdoll","Anti ragdoll","Anti ragdoll","Anti ragdoll","Anti ragdoll","Anti ragdoll","Anti ragdoll","Anti ragdoll")
_addUIText("Auto Revive","Auto Revive","Auto revivir","Auto reviver","Auto revive","Auto revive","Auto Revive","Auto revive","Auto revive","Tu dong cuu","Auto revive","Oto canlandir","Auto revive","Auto revive","Zidong fuhuo","Avto ozhivlenie")
_addUIText("Revive Radius","Radius Revive","Radio revive","Raio revive","Jejari revive","Revive radius","Revive Radius","Rayon revive","Nisf qutr revive","Ban kinh revive","Radius revive","Revive yaricapi","Revive hankei","Revive bandgyeong","Revive banjing","Radius ozhivleniya")
_addUIText("Teleport Tools","Alat Teleport","Herramientas teleport","Ferramentas teleport","Alat teleport","Teleport tools","Teleport Tools","Outils teleport","Adawat teleport","Cong cu teleport","Khrueang mue teleport","Teleport araclari","Teleport tools","Teleport tools","Chuansong gongju","Instrumenty teleporta")
_addUIText("Tween to Base/Generator","Tween ke Base/Generator","Tween a base/generador","Tween para base/gerador","Tween ke base/generator","Tween to base/generator","Tween zur Base/Generator","Tween vers base/generateur","Tween ila base/generator","Tween toi base/may phat","Tween pai base/generator","Base/generator tween","Base/generator e tween","Base/generator tween","Tween dao jidi/fadianji","Tween k baze/generatoru")
_addUIText("Select Player","Pilih Pemain","Seleccionar jugador","Selecionar jogador","Pilih pemain","Pili player","Spieler waehlen","Choisir joueur","Ikhtar player","Chon nguoi choi","Lueak phu len","Oyuncu sec","Player sentaku","Player seontaek","Xuanze wanjia","Vybrat igroka")
_addUIText("Teleport to Player","Teleport ke Pemain","Teleportar a jugador","Teleportar para jogador","Teleport ke pemain","Teleport to player","Zum Spieler teleportieren","Teleport vers joueur","Teleport ila player","Dich chuyen toi nguoi choi","Teleport pai phu len","Oyuncuya teleport","Player e teleport","Player ro teleport","Chuansong dao wanjia","Teleport k igroku")
_addUIText("Class Avatar Cloner","Kloning Avatar Class","Clonar avatar de clase","Clonar avatar de classe","Klon avatar kelas","I-clone avatar ng class","Klassen-Avatar klonen","Cloner avatar de classe","Istinsakh avatar al-fiah","Sao chep avatar class","Clone avatar class","Sinif avatarini kopyala","Kurasu abata fukusei","Keullaeseu abata boksa","Fuzhi zhiye touxiang","Klonirovat avatar klassa")
_addUIText("Select Class Avatar","Pilih Avatar Class","Seleccionar avatar de clase","Selecionar avatar da classe","Pilih avatar kelas","Piliin avatar ng class","Klassen-Avatar waehlen","Choisir avatar de classe","Ikhtar avatar al-fiah","Chon avatar class","Lueak avatar class","Sinif avatari sec","Kurasu abata sentaku","Keullaeseu abata seontaek","Xuanze zhiye touxiang","Vybrat avatar klassa")
_addUIText("Apply Class Avatar","Terapkan Avatar Class","Aplicar avatar de clase","Aplicar avatar da classe","Gunakan avatar kelas","Ilapat avatar ng class","Klassen-Avatar anwenden","Appliquer avatar de classe","Tatbiq avatar al-fiah","Ap dung avatar class","Chai avatar class","Sinif avatarini uygula","Kurasu abata tekiyou","Keullaeseu abata jeok-yong","Yingyong zhiye touxiang","Primenit avatar klassa")
_addUIText("Scan Lobby Classes","Scan Class di Lobby","Escanear clases en lobby","Escanear classes no lobby","Imbas kelas di lobi","I-scan mga class sa lobby","Lobby-Klassen scannen","Scanner classes du lobby","Mashh fiah al-lobby","Quet class trong lobby","Scan class nai lobby","Lobideki siniflari tara","Robi no kurasu wo sukyan","Lobi keullaeseu seukaen","Saomiao dateng zhiye","Skanirovat klassy v lobbi")
_addUIText("Reset Avatar","Reset Avatar","Restablecer avatar","Restaurar avatar","Reset avatar","I-reset ang avatar","Avatar zuruecksetzen","Reinitialiser avatar","Iadat dhabtt al-avatar","Dat lai avatar","Reset avatar","Avatari sifirla","Abata wo risetto","Abata chocigiwha","Chongzhi touxiang","Sbrosit avatar")
_addUIText("Delete Selected Class","Hapus Class Terpilih","Eliminar clase seleccionada","Excluir classe selecionada","Padam kelas dipilih","I-delete napiling class","Ausgewaehlte Klasse loeschen","Supprimer classe selectionnee","Hadhf al-fiah al-mukhtarah","Xoa class da chon","Lop class thi lueak","Secilen sinifi sil","Sentaku shita kurasu wo sakujo","Seontaekdoen keullaeseu sakje","Shanchu suoxuan zhiye","Udalit vybrannyy klass")
_addUIText("Aim Lock","Aim Lock","Bloqueo de mira","Bloqueio de mira","Kunci bidikan","Aim Lock","Aim Lock","Verrouillage de visee","Qufl al-tasdib","Khoa muc tieu","Lock pao","Nisan kilidi","Eimu rokku","Eim lok","Miaozhun suoding","Avtopritsel")
_addUIText("Aim Lock Keybind","Keybind Aim Lock","Atajo bloqueo mira","Atalho bloqueio mira","Keybind kunci bidik","Aim lock keybind","Aim-Lock-Tastenbindung","Raccourci verrouillage","Rabt miftah qufl","Phim tat khoa muc tieu","Keybind lock pao","Nisan kilidi kisayolu","Eimu rokku kii","Eim lok kibain","Miaozhun suoding anjian","Privyazka avtopritsela")
_addUIText("Smoothness","Kelancaran (Smooth)","Suavidad","Suavidade","Kelancaran","Kakinisan","Glaettung","Fluidite","Sulasah","Do muot","Khwam luen","Puruessuzluk","Namerakasa","Budeureoum","Pinghuadu","Plavnost")
_addUIText("FOV Radius","Radius FOV","Radio FOV","Raio FOV","Jejari FOV","Radius ng FOV","FOV-Radius","Rayon FOV","Nisf qutr FOV","Ban kinh FOV","Ratsami FOV","FOV yaricapi","FOV hankei","FOV banji","FOV banjing","Radius FOV")
_addUIText("Wall Check","Cek Dinding","Verificar pared","Verificar parede","Semak dinding","I-check ang pader","Wand-Check","Verification mur","Fahs al-jidar","Kiem tra tuong","Trowat sap kamphaeng","Duvar kontrolu","Kabe chekku","Byeok chekeu","Qiangbi jiancha","Proverka sten")
_addUIText("Silent Aim Target","Target Silent Aim","Objetivo Silent Aim","Alvo Silent Aim","Sasaran Silent Aim","Silent Aim target","Silent-Aim-Ziel","Cible Silent Aim","Hadaf Silent Aim","Muc tieu Silent Aim","Pao mai Silent Aim","Silent Aim hedefi","Silent Aim taagetto","Silent Aim ta-get","Silent Aim mubiao","Tsel Silent Aim")
_addUIText("Silent Aim Part","Bagian Silent Aim","Parte Silent Aim","Parte Silent Aim","Bahagian Silent Aim","Parte ng Silent Aim","Silent-Aim-Koerperteil","Partie Silent Aim","Juz Silent Aim","Bo phan Silent Aim","Suan Silent Aim","Silent Aim bolumu","Silent Aim bui","Silent Aim buwi","Silent Aim buwei","Chast tela Silent Aim")
_addUIText("Silent Aim Range","Jarak Silent Aim","Rango Silent Aim","Alcance Silent Aim","Jarak Silent Aim","Distansya ng Silent Aim","Silent-Aim-Reichweite","Portee Silent Aim","Mada Silent Aim","Tam Silent Aim","Raya Silent Aim","Silent Aim menzili","Silent Aim han-i","Silent Aim beomwi","Silent Aim fanwei","Distantsiya Silent Aim")
_addUIText("Lock Distance","Jarak Kunci (Distance)","Distancia de bloqueo","Distancia de bloqueio","Jarak kunci","Distansya ng lock","Sperrabstand","Distance de verrouillage","Masafat al-qufl","Khoang cach khoa","Raya lock","Kilit mesafesi","Rokku kyori","Jamgeum geori","Suoding juli","Distantsiya fiksatsii")
_addUIText("Mobile Quick Button","Tombol Cepat Mobile","Boton rapido movil","Botao rapido movel","Butang pantas mudah alih","Mobile quick button","Mobile-Schnellschaltflaeche","Bouton rapide mobile","Zirr sari lil-jawwal","Nut nhanh di dong","Pum tat mue thue","Mobil hizli dugme","Mobairu kuikku botan","Mobail kwik beoteun","Yidongduan kuaijie anniu","Bystraya knopka dlya mobilnykh")
_addUIText("Lock Button Position","Kunci Posisi Tombol","Bloquear posicion del boton","Bloquear posicao do botao","Kunci kedudukan butang","I-lock ang posisyon ng button","Schaltflaechenposition sperren","Verrouiller position bouton","Qufl mawqie al-zirr","Khoa vi tri nut","Lock tamnaeng pum","Dugme konumunu kilitle","Botan no ichi wo rokku","Beoteun wichi jamgeum","Suoding anniu weizhi","Zafiksirovat pozitsiyu knopki")
local ModernV2
local _LANG_TEXT_SOURCES = {}
local _LANG_UPDATERS = {} -- [FIX] Registry updater untuk setiap elemen UI

local function _trackLangText(text)
    if type(text) == "string" and text ~= "" then
        _LANG_TEXT_SOURCES[text] = true
    end
    return text
end

local function TUIFor(lang, text)
    if type(text) ~= "string" or text == "" then return text end
    if lang == "EN" then return text end
    local found = _UI_TEXT[text]
    if found and found[lang] then return found[lang] end
    for _, row in pairs(_DICT) do
        if type(row) == "table" and row.EN == text then
            return row[lang] or row.EN or text
        end
    end
    return text
end

local function TUI(text)
    return TUIFor(_LANG, text)
end

local function _seedLangSources()
    for src in pairs(_UI_TEXT) do _trackLangText(src) end
    for _, row in pairs(_DICT) do
        if type(row) == "table" and type(row.EN) == "string" then
            _trackLangText(row.EN)
        end
    end
end
_seedLangSources()

local function RefreshLanguageUI(oldLang, newLang)
    oldLang = oldLang or "EN"
    newLang = newLang or _LANG or "EN"

    -- Kumpulkan semua root GUI
    local roots = {}
    pcall(function() if ModernV2 and ModernV2.ScreenGui then table.insert(roots, ModernV2.ScreenGui) end end)
    pcall(function()
        local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local notif = pg:FindFirstChild("SolanaHubNotif")
            local keybind = pg:FindFirstChild("SolanaHubKeybindMenu")
            if notif then table.insert(roots, notif) end
            if keybind then table.insert(roots, keybind) end
        end
    end)

    -- [FIX] Bangun peta terjemahan UNIVERSAL: semua bahasa -> bahasa baru
    -- Ini memastikan teks dalam bahasa APAPUN yang sedang tampil akan ter-replace
    local allLangs = {"ID","EN","ES","PT","MS","TL","DE","FR","AR","VI","TH","TR","JA","KO","ZH","RU"}
    local replacements = {}

    -- Dari _UI_TEXT (semua entry yang didaftarkan via _addUIText)
    for enSource, row in pairs(_UI_TEXT) do
        if type(row) == "table" then
            local target = row[newLang] or row["EN"] or enSource
            -- Daftarkan semua varian bahasa dari teks ini sebagai key
            for _, lang in ipairs(allLangs) do
                local variant = row[lang]
                if variant and variant ~= "" then
                    replacements[variant] = target
                end
            end
            -- Juga daftarkan key EN asli
            replacements[enSource] = target
        end
    end

    -- Dari _DICT (tab names, dll)
    for _, row in pairs(_DICT) do
        if type(row) == "table" then
            local target = row[newLang] or row["EN"] or ""
            for _, lang in ipairs(allLangs) do
                local variant = row[lang]
                if variant and variant ~= "" then
                    replacements[variant] = target
                end
            end
        end
    end

    -- Ganti semua teks di seluruh GUI (untuk tab yang sudah di-render)
    for _, root in ipairs(roots) do
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local currentText = obj.Text
                if currentText and currentText ~= "" then
                    local Solt = replacements[currentText]
                    if Solt and Solt ~= currentText then
                        obj.Text = Solt
                    end
                end
                if obj:IsA("TextBox") then
                    local ph = obj.PlaceholderText
                    if ph and ph ~= "" then
                        local SoltPh = replacements[ph]
                        if SoltPh then obj.PlaceholderText = SoltPh end
                    end
                end
            end
        end
    end

    -- [FIX] Jalankan semua updater yang terdaftar (mencakup tab yang belum dibuka)
    for _, updater in ipairs(_LANG_UPDATERS) do
        pcall(updater)
    end
end

-- REMOTES
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
pickUpItemRemote = Remotes and Remotes:FindFirstChild("Interaction") and Remotes.Interaction:FindFirstChild("PickUpItem")
placeStructureRemote = Remotes and Remotes:FindFirstChild("Building") and Remotes.Building:FindFirstChild("PlaceStructure")
buyItemRemote = Remotes and Remotes:FindFirstChild("Merchant") and Remotes.Merchant:FindFirstChild("BuyItem")
addSuppressorRemote = Remotes and Remotes:FindFirstChild("Tools") and Remotes.Tools:FindFirstChild("AddSuppressor")
adjustBackpackRemote = Remotes and Remotes:FindFirstChild("Tools") and Remotes.Tools:FindFirstChild("AdjustBackpack")
resetRemote = Remotes and Remotes:FindFirstChild("Misc") and Remotes.Misc:FindFirstChild("Reset")

function getPickUpRemote()
    local R = ReplicatedStorage:FindFirstChild("Remotes")
    return R and R:FindFirstChild("Interaction") and R.Interaction:FindFirstChild("PickUpItem")
end
function getAdjustBackpackRemote()
    local R = ReplicatedStorage:FindFirstChild("Remotes")
    return R and R:FindFirstChild("Tools") and R.Tools:FindFirstChild("AdjustBackpack")
end

-- ============================================
-- MODERNV2 UI FRAMEWORK
-- ============================================
local success
success, ModernV2 = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/SolanaHubmy/ggsolana/refs/heads/main/SolanaHub-ModernV2.txt"))()
end)
if not success or not ModernV2 then
    warn("[SolanaHub] ModernV2 UI failed to load.")
    return
end

if not game:IsLoaded() then game.Loaded:Wait() end

-- Global tables  - Â diakses oleh game logic di seluruh script
Options = {}
Toggles = {}
Library = nil  -- diisi setelah do block
Tabs    = nil  -- diisi setelah do block
Window  = nil  -- diisi setelah do block

-- ============================================
-- UI HELPER WRAPPER (do block = free outer scope locals)
-- Lua limit: 200 locals per scope. Wrap helpers di sini
-- supaya tidak menambah locals ke outer scope.
-- ============================================

-- Window setup (harus di luar do block agar _window bisa diakses di dalam)
ModernV2:AddTheme({
    Name = "Lumi Purple",
    Accent = Color3.fromRGB(220, 35, 55),
    Background = Color3.fromRGB(8, 8, 13),
    Surface = Color3.fromRGB(20, 22, 27),
    Outline = Color3.fromRGB(45, 48, 58),
    Text = Color3.fromRGB(255, 255, 255),
    Placeholder = Color3.fromRGB(140, 140, 155),
    Button = Color3.fromRGB(220, 35, 55),
    Icon = Color3.fromRGB(255, 255, 255),
})

local _menuIcon = ModernV2:CreateMenuIcon({
    Image = "rbxassetid://135199868370962",
    Size = 48, IconColor = Color3.fromRGB(255, 255, 255),
    BGColor = Color3.fromRGB(20, 22, 27),
    StrokeColor = Color3.fromRGB(220, 35, 55), StrokeThick = 1.5, Draggable = true,
})

local _window = ModernV2:Window({
    Title = "Solana Hub",
    Content = "Survive The Apocalypse v1.7.9 | Developer: Opixx",
    Image = "135199868370962",
    Color = Color3.fromRGB(220, 35, 55),
    Uitransparent = 0.15,
    ShowUser = true, Search = true, ConfigEnabled = true,
    NotifyOnCallbackError = false, LoadingScreen = false,
    Enable3DRenderer = false, Keybind = "RightControl",
    Size = UDim2.fromOffset(540, 340),
    Config = {
        ConfigFolder = "SolanaHubSTA",
        AutoSaveFile = "survive-the-apocalypse",
        AutoSave = false, AutoLoad = false, Overwrite = true,
        Format = "JSON", ShowAutoSaveToggle = false, TextGradient = true,
    },
})

_window:AttachMenuIcon(_menuIcon)
_window:SetAccount({Username = LocalPlayer.DisplayName, Profile = ModernV2.UserProfile, Expires = "Never"})

_window:CreateHomeTab({
    Name = "Dashboard", Icon = "lucide:layout-dashboard",
    Content = "Solana Hub Survive The Apocalypse Script",
    DiscordInvite = "https://discord.gg/jdmX43t5mY",
    SupportedExecutors = {"Delta", "Synapse X", "Krnl", "Codex", "Arceus X"},
    UnsupportedExecutors = {"Roblox Studio"},
    Segments = {
        Details = {Text = "Details", Icon = "lucide:grid-2x2"},
        Script  = {Text = "Script Logs", Icon = "lucide:code"},
        UI      = {Text = "UI Logs", Icon = "lucide:file-text", Show = true},
    },
    Changelog = {
        {Title = "STA v1.7.9", Description = "Fixed Auto Pickup logic forcing weapons into Backpack causing void bugs. Fixed Auto Trash filtering. Added Necromancer class check for Silent Aim. Miscellaneous bug fixes and stability improvements."},
        {Title = "STA v1.7.8", Description = "Refactored overall script architecture for better performance. Updated UI Framework. Optimized loops and connections."},
    },
    UIChangelog = {
        {Title = "ModernV2 Style", Description = "Redesigned with Double-column sections, stacked labels, and red accent."},
    },
})

-- Mini notif ScreenGui
local _notifGui = Instance.new("ScreenGui")
_notifGui.Name = "SolanaHubNotif"; _notifGui.ResetOnSpawn = false
_notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() _notifGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

local function _initLibrary()
    local _noop = function() end
    local unloadCallbacks = {}

    -- OptionStore factory
    local function _mkOptionStore(flag, default, targetTable)
        local obj = { Value = default }
        function obj:SetValue(v) self.Value = v end
        obj.Set = obj.SetValue
        targetTable[flag] = obj
        return obj
    end

    local function _normalizeMulti(v)
        if type(v) ~= "table" then return {} end
        local out = {}
        local hasStringKey = false
        for k, val in pairs(v) do
            if type(k) == "string" then hasStringKey = true; out[k] = val and true or false end
        end
        if hasStringKey then return out end
        for _, name in ipairs(v) do out[tostring(name)] = true end
        return out
    end

    local function _toIncrement(rounding)
        if type(rounding) == "number" and rounding > 0 then return 10 ^ (-rounding) end
        return 1
    end

    -- Section wrapper factory
    local function _wrapSection(sec)
        local group = {}

        function group:AddToggle(flag, cfg)
            cfg = cfg or {}
            local default = cfg.Default and true or false
            local slot = _mkOptionStore(flag, default, Toggles)
            local labelText = _trackLangText(cfg.Text or flag)
            local isPremium = cfg.Premium == true
            local isLocked = false -- Solana Hub: all features unlocked
            local elem = sec:AddToggle({
                Name = TUI(labelText), Flag = "STA_"..flag, Default = default,
                Locked = isLocked,
                TextLocked = isLocked and "Premium Required" or nil,
                Callback = function(v)
                    if isLocked and v then
                        slot:SetValue(false)
                        Library:Notify({
                            Title = "Premium Required âœ¨",
                            Description = "Fitur " .. TUI(labelText) .. " hanya untuk pengguna Key Premium!",
                            Time = 5
                        })
                        return
                    end
                    slot.Value = v and true or false
                    if cfg.Callback then cfg.Callback(slot.Value) end
                end,
            })
            -- [FIX] Daftarkan updater: saat ganti bahasa, scan frame toggle & update TextLabel
            table.insert(_LANG_UPDATERS, function()
                pcall(function()
                    if elem and elem.Frame then
                        for _, obj in ipairs(elem.Frame:GetDescendants()) do
                            if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text == TUIFor(_LANG == TUIFor("EN", labelText) and "EN" or _LANG, labelText) then
                                obj.Text = TUI(labelText)
                            end
                        end
                    end
                end)
            end)
            function slot:SetValue(v)
                v = v and true or false; self.Value = v
                if elem and elem.Set then elem:Set(v)
                elseif cfg.Callback then cfg.Callback(v) end
            end
            slot.Set = slot.SetValue
            -- ColorPicker chaining
            local function _addCP(cpFlag, cpCfg)
                cpCfg = cpCfg or {}
                local cpDefault = cpCfg.Default or Color3.fromRGB(255,255,255)
                local cpStore = _mkOptionStore(cpFlag, cpDefault, Options)
                local cpElem = nil
                pcall(function()
                    if sec.AddColorPicker then
                        cpElem = sec:AddColorPicker({Name = cpCfg.Title or cpFlag, Flag = "STA_"..cpFlag, Default = cpDefault,
                            Callback = function(v) cpStore.Value = v; if cpCfg.Callback then cpCfg.Callback(v) end end})
                    end
                end)
                function cpStore:SetValue(v) self.Value = v; if cpElem and cpElem.Set then cpElem:Set(v) elseif cpCfg.Callback then cpCfg.Callback(v) end end
                cpStore.Set = cpStore.SetValue
                return slot
            end
            slot.AddColorPicker = function(_, f, c) return _addCP(f, c) end
            slot.AddColorpicker = slot.AddColorPicker

            -- KeyPicker chaining on Toggle (for Linoria-style toggle:AddKeyPicker)
            local function _addKP(kFlag, kCfg)
                kCfg = kCfg or {}
                local kDefault = kCfg.Default or "None"
                if typeof(kDefault) == "EnumItem" then kDefault = kDefault.Name end
                local kSlot = _mkOptionStore(kFlag, kDefault, Options)
                pcall(function()
                    if sec.AddKeybind then
                        local labelText = _trackLangText(kCfg.Text or kFlag)
                        local kb = sec:AddKeybind({
                            Name = TUI(labelText),
                            Flag = "STA_"..kFlag,
                            Default = kDefault,
                            Mode = kCfg.Mode or "Toggle",
                            ChangedCallback = function(keyName)
                                local keyStr = tostring(keyName or "")
                                if typeof(keyName) == "EnumItem" then keyStr = keyName.Name end
                                if keyStr ~= "" and keyStr ~= "None" and keyStr ~= "nil" and keyStr ~= "true" and keyStr ~= "false" then
                                    kSlot.Value = keyStr
                                    if kCfg.ChangedCallback then kCfg.ChangedCallback(keyStr) end
                                    if kCfg.NoUI and kCfg.Callback then kCfg.Callback(keyStr) end
                                end
                            end,
                            Callback = function(state)
                                if type(state) == "boolean" then
                                    kSlot.State = state
                                    if kCfg.Callback then
                                        kCfg.Callback(state)
                                    elseif slot and slot.SetValue then
                                        slot:SetValue(state)
                                    end
                                elseif type(state) == "string" and (state == "true" or state == "false") then
                                    local bState = (state == "true")
                                    kSlot.State = bState
                                    if kCfg.Callback then
                                        kCfg.Callback(bState)
                                    elseif slot and slot.SetValue then
                                        slot:SetValue(bState)
                                    end
                                elseif type(state) == "string" and state ~= "None" and state ~= "nil" then
                                    kSlot.Value = state
                                    if kCfg.ChangedCallback then kCfg.ChangedCallback(state) end
                                    if kCfg.NoUI and kCfg.Callback then kCfg.Callback(state) end
                                end
                            end,
                        })
                        function kSlot:GetState()
                            if kb and kb.GetState then return kb:GetState() end
                            return self.State or false
                        end
                        function kSlot:SetValue(v)
                            if type(v) == "boolean" then
                                self.State = v
                                if kb and kb.SetState then kb:SetState(v) end
                                if kCfg.Callback then kCfg.Callback(v) end
                                return
                            end
                            local keyStr = tostring(v or "")
                            if typeof(v) == "EnumItem" then keyStr = v.Name end
                            if keyStr ~= "" and keyStr ~= "None" and keyStr ~= "nil" and keyStr ~= "true" and keyStr ~= "false" then
                                self.Value = keyStr
                                if kb and kb.SetValue then kb:SetValue(keyStr) end
                                if kCfg.ChangedCallback then kCfg.ChangedCallback(keyStr) end
                            end
                        end
                        kSlot.Set = kSlot.SetValue
                    end
                end)
                return slot
            end
            slot.AddKeyPicker = function(_, f, c) return _addKP(f, c) end
            slot.AddKeypicker = slot.AddKeyPicker

            return slot
        end

        function group:AddSlider(flag, cfg)
            cfg = cfg or {}
            local default = cfg.Default; if default == nil then default = cfg.Min or 0 end
            local slot = _mkOptionStore(flag, default, Options)
            -- SetStacked(true) = label di atas penuh, slider di bawah (sesuai MainV2 source)
            local labelText = _trackLangText(cfg.Text or flag)
            local lbl = sec:AddLabel(TUI(labelText), true)
            lbl:SetStacked(true)
            table.insert(_LANG_UPDATERS, function()
                pcall(function() if lbl and lbl.SetText then lbl:SetText(TUI(labelText)) end end)
            end)
            local isPremium = cfg.Premium == true
            local isLocked = false -- Solana Hub: all features unlocked
            local elem = lbl:AddSlider({
                Flag = "STA_"..flag, Min = cfg.Min or 0, Max = cfg.Max or 100,
                Default = default, Rounding = cfg.Rounding or 0,
                Locked = isLocked,
                TextLocked = isLocked and "Premium Required" or nil,
                Callback = function(v)
                    if isLocked then return end
                    slot.Value = v; if cfg.Callback then cfg.Callback(v) end
                end,
            })
            function slot:SetValue(v) self.Value = v; if elem and elem.Set then elem:Set(v) elseif cfg.Callback then cfg.Callback(v) end end
            slot.Set = slot.SetValue
            return slot
        end

        function group:AddDropdown(flag, cfg)
            cfg = cfg or {}
            local values = cfg.Values or {}
            local multi = cfg.Multi == true
            local default = cfg.Default
            if type(default) == "number" then default = values[default] end
            local slot = _mkOptionStore(flag, default, Options)
            slot.Values = values
            -- SetStacked(true) = label di atas penuh, dropdown di bawah
            local labelText = _trackLangText(cfg.Text or flag)
            local lbl = sec:AddLabel(TUI(labelText), true)
            lbl:SetStacked(true)
            -- [FIX] Daftarkan updater
            table.insert(_LANG_UPDATERS, function()
                pcall(function() if lbl and lbl.SetText then lbl:SetText(TUI(labelText)) end end)
            end)
            local isPremium = cfg.Premium == true
            local isLocked = false -- Solana Hub: all features unlocked
            local _elem = lbl:AddDropdown({
                Flag = "STA_"..flag, Values = values, Multi = multi, Default = default,
                Search = true,
                Locked = isLocked,
                TextLocked = isLocked and "Premium Required" or nil,
                Callback = function(v)
                    if isLocked then return end
                    slot.Value = v; if cfg.Callback then cfg.Callback(v) end
                end,
            })
            function slot:SetValues(newVals)
                self.Values = newVals or {}
                pcall(function() if _elem and _elem.SetValues then _elem:SetValues(self.Values) end end)
            end
            function slot:SetValue(v) self.Value = v; if _elem and _elem.Set then _elem:Set(v) elseif cfg.Callback then cfg.Callback(v) end end
            slot.Set = slot.SetValue
            return slot
        end

        function group:AddButton(text, callback, cfg)
            cfg = cfg or {}
            local labelText = _trackLangText(tostring(text or "Button"))
            local isPremium = cfg.Premium == true
            local isLocked = false -- Solana Hub: all features unlocked
            local btnElem = sec:AddButton({Name = TUI(labelText), Icon = "lucide:play",
                Locked = isLocked,
                TextLocked = isLocked and "Premium Required" or nil,
                Callback = function()
                    if isLocked then
                        Library:Notify({
                            Title = "Premium Required âœ¨",
                            Description = "Fitur " .. TUI(labelText) .. " hanya untuk pengguna Key Premium!",
                            Time = 5
                        })
                        return
                    end
                    if callback then callback() end
                end})
            -- [FIX] Daftarkan updater button
            table.insert(_LANG_UPDATERS, function()
                pcall(function()
                    if btnElem and btnElem.Frame then
                        for _, obj in ipairs(btnElem.Frame:GetDescendants()) do
                            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                                if obj.Text ~= "" then obj.Text = TUI(labelText) end
                            end
                        end
                    end
                end)
            end)
        end

        function group:AddDivider(arg)
            local divText = ""
            if type(arg) == "string" then
                divText = arg
            elseif type(arg) == "table" then
                divText = arg.Text or arg.Name or ""
            end
            
            pcall(function()
                if sec.AddDivider then
                    local cfg = {}
                    if divText ~= "" then
                        local sourceText = _trackLangText(divText)
                        cfg.Text = TUI(sourceText)
                        local dElem = sec:AddDivider(cfg)
                        table.insert(_LANG_UPDATERS, function()
                            pcall(function()
                                if dElem and dElem.SetText then
                                    dElem:SetText(TUI(sourceText))
                                elseif dElem and (dElem.Frame or dElem.Instance) then
                                    for _, obj in ipairs((dElem.Frame or dElem.Instance):GetDescendants()) do
                                        if obj:IsA("TextLabel") then
                                            obj.Text = TUI(sourceText)
                                        end
                                    end
                                end
                            end)
                        end)
                    else
                        sec:AddDivider({})
                    end
                end
            end)
        end

        function group:AddLabel(text, cfg)
            cfg = cfg or {}
            local labelObj = {}
            -- Actually render the label in the UI
            pcall(function()
                if sec.AddLabel then
                    local sourceText = _trackLangText(tostring(text or ""))
                    local rendered = sec:AddLabel(TUI(sourceText), false)
                    
                    local function _applyStyle()
                        pcall(function()
                            if rendered and (rendered.Frame or rendered.Instance or rendered.Label) then
                                local root = rendered.Frame or rendered.Instance or rendered.Label
                                for _, obj in ipairs(root:GetDescendants()) do
                                    if obj:IsA("TextLabel") then
                                        if cfg.Center then
                                            obj.TextXAlignment = Enum.TextXAlignment.Center
                                            obj.TextColor3 = Color3.fromRGB(175, 175, 195)
                                            obj.Font = Enum.Font.GothamMedium
                                            obj.TextSize = 13
                                        end
                                    end
                                end
                                if root:IsA("TextLabel") and cfg.Center then
                                    root.TextXAlignment = Enum.TextXAlignment.Center
                                    root.TextColor3 = Color3.fromRGB(175, 175, 195)
                                    root.Font = Enum.Font.GothamMedium
                                    root.TextSize = 13
                                end
                            end
                        end)
                    end
                    _applyStyle()

                    -- [FIX] Daftarkan updater
                    table.insert(_LANG_UPDATERS, function()
                        pcall(function()
                            if rendered and rendered.SetText then
                                rendered:SetText(TUI(sourceText))
                                _applyStyle()
                            end
                        end)
                    end)
                    function labelObj:SetText(t)
                        local SoltText = _trackLangText(tostring(t or ""))
                        if rendered and rendered.SetText then
                            rendered:SetText(TUI(SoltText))
                            _applyStyle()
                        end
                    end
                end
            end)
            if not labelObj.SetText then
                function labelObj:SetText(_) end
            end
            function labelObj:AddKeyPicker(kFlag, kCfg)
                kCfg = kCfg or {}
                local kDefault = kCfg.Default or "RightShift"
                if typeof(kDefault) == "EnumItem" then kDefault = kDefault.Name end
                local kSlot = _mkOptionStore(kFlag, kDefault, Options)
                pcall(function()
                    if sec.AddKeybind then
                        local labelText = _trackLangText(kCfg.Text or kFlag)
                        local kb = sec:AddKeybind({
                            Name = TUI(labelText),
                            Flag = "STA_"..kFlag,
                            Default = kDefault,
                            Mode = kCfg.Mode or "Toggle",
                            ChangedCallback = function(keyName)
                                local keyStr = tostring(keyName or "")
                                if typeof(keyName) == "EnumItem" then keyStr = keyName.Name end
                                if keyStr ~= "" and keyStr ~= "None" and keyStr ~= "nil" and keyStr ~= "true" and keyStr ~= "false" then
                                    kSlot.Value = keyStr
                                    if kCfg.ChangedCallback then kCfg.ChangedCallback(keyStr) end
                                    if kCfg.NoUI and kCfg.Callback then kCfg.Callback(keyStr) end
                                end
                            end,
                            Callback = function(state)
                                if type(state) == "boolean" then
                                    kSlot.State = state
                                    if kCfg.Callback then kCfg.Callback(state) end
                                elseif type(state) == "string" and (state == "true" or state == "false") then
                                    local bState = (state == "true")
                                    kSlot.State = bState
                                    if kCfg.Callback then kCfg.Callback(bState) end
                                elseif type(state) == "string" and state ~= "None" and state ~= "nil" then
                                    kSlot.Value = state
                                    if kCfg.ChangedCallback then kCfg.ChangedCallback(state) end
                                    if kCfg.NoUI and kCfg.Callback then kCfg.Callback(state) end
                                end
                            end
                        })
                        function kSlot:SetValue(v)
                            if type(v) == "boolean" then
                                self.State = v
                                if kb and kb.SetState then kb:SetState(v) end
                                if kCfg.Callback then kCfg.Callback(v) end
                                return
                            end
                            local keyStr = tostring(v or "")
                            if typeof(v) == "EnumItem" then keyStr = v.Name end
                            if keyStr ~= "" and keyStr ~= "None" and keyStr ~= "nil" and keyStr ~= "true" and keyStr ~= "false" then
                                self.Value = keyStr
                                if kb and kb.SetValue then kb:SetValue(keyStr) end
                                if kCfg.ChangedCallback then kCfg.ChangedCallback(keyStr) end
                            end
                        end
                        function kSlot:GetState()
                            if kb and kb.GetState then return kb:GetState() end
                            return self.State or false
                        end
                        kSlot.Set = kSlot.SetValue
                    end
                end)
                return kSlot
            end
            return labelObj
        end

        return group
    end

    -- Tab wrapper factory
    local function _makeTabWrapper(tab)
        local obj = {}
        function obj:AddLeftGroupbox(title)
            local sourceTitle = _trackLangText(title)
            local sec = tab:AddSection({Name = TUI(sourceTitle), Position = "Left", Box = true, BoxBorder = true, Opened = true})
            -- [FIX] Updater judul section
            table.insert(_LANG_UPDATERS, function()
                pcall(function() if sec and sec.SetName then sec:SetName(TUI(sourceTitle)) end end)
                pcall(function()
                    if sec and sec.Frame then
                        for _, obj2 in ipairs(sec.Frame:GetDescendants()) do
                            if (obj2:IsA("TextLabel") or obj2:IsA("TextButton")) and obj2.Text == TUIFor(_LANG, sourceTitle) then
                                obj2.Text = TUI(sourceTitle)
                            end
                        end
                    end
                end)
            end)
            return _wrapSection(sec)
        end
        function obj:AddRightGroupbox(title)
            local sourceTitle = _trackLangText(title)
            local sec = tab:AddSection({Name = TUI(sourceTitle), Position = "Right", Box = true, BoxBorder = true, Opened = true})
            table.insert(_LANG_UPDATERS, function()
                pcall(function() if sec and sec.SetName then sec:SetName(TUI(sourceTitle)) end end)
            end)
            return _wrapSection(sec)
        end
        function obj:AddCenterGroupbox(title)
            local sourceTitle = _trackLangText(title)
            local sec = tab:AddSection({Name = TUI(sourceTitle), Position = "Center", Box = true, BoxBorder = true, Opened = true})
            table.insert(_LANG_UPDATERS, function()
                pcall(function() if sec and sec.SetName then sec:SetName(TUI(sourceTitle)) end end)
            end)
            return _wrapSection(sec)
        end
        function obj:AddSection(cfg)
            local sourceTitle = _trackLangText((type(cfg)=="table" and cfg.Title) or "Section")
            local sec = tab:AddSection({Name = TUI(sourceTitle), Position = "Left", Box = true, BoxBorder = true, Opened = false})
            table.insert(_LANG_UPDATERS, function()
                pcall(function() if sec and sec.SetName then sec:SetName(TUI(sourceTitle)) end end)
            end)
            return _wrapSection(sec)
        end
        function obj:AddCenterTabbox(name)
            local sourceName = _trackLangText(name)
            local tabbox = tab:AddCenterTabbox(TUI(sourceName))
            local wrappedTabbox = {}
            function wrappedTabbox:AddTab(cfg)
                cfg = cfg or {}
                local labelText = _trackLangText(cfg.Name or "")
                local rawTab = tabbox:AddTab({
                    Name = TUI(labelText),
                    Icon = cfg.Icon or ""
                })
                table.insert(_LANG_UPDATERS, function()
                    pcall(function()
                        if rawTab and rawTab.SetName then
                            rawTab:SetName(TUI(labelText))
                        end
                    end)
                end)
                return _wrapSection(rawTab)
            end
            return wrappedTabbox
        end
        return obj
    end

    -- Create tabs
    local tVis = _window:AddTab({Name = TUI(_trackLangText("Visuals")),     Icon = "lucide:eye",       Type = "Double"})
    local tPlr = _window:AddTab({Name = TUI(_trackLangText("Player")),      Icon = "lucide:user",      Type = "Double"})
    local tCbt = _window:AddTab({Name = TUI(_trackLangText("Combat")),      Icon = "lucide:crosshair", Type = "Double"})
    local tExp = _window:AddTab({Name = TUI(_trackLangText("Auto Play")),   Icon = "lucide:zap",       Type = "Double"})
    local tMsc = _window:AddTab({Name = TUI(_trackLangText("Misc")),        Icon = "lucide:settings",  Type = "Double"})
    local tUI  = _window:AddTab({Name = TUI(_trackLangText("UI Settings")), Icon = "lucide:cog",       Type = "Double"})

    -- Assign globals
    Tabs = {
        Visuals         = _makeTabWrapper(tVis),
        Player          = _makeTabWrapper(tPlr),
        Combat          = _makeTabWrapper(tCbt),
        Exploits        = _makeTabWrapper(tExp),
        Misc            = _makeTabWrapper(tMsc),
        ["UI Settings"] = _makeTabWrapper(tUI),
    }

    -- Library shim (global)
    Library = {
        Options = Options, Toggles = Toggles,
        ForceCheckbox = false,
        ShowToggleFrameInKeybinds = true,
        ShowCustomCursor = true,
        KeybindFrame = { Visible = false },
        CornerRadius = 6,
        NotifySide = "Right",
        DPIScale = 100,
        Unloaded = false,
    }
    function Library:Notify(cfg)
        if _G._SolanaHubNotifySuppressed then return end
        cfg = cfg or {}
        -- Mini notif lightweight
        local title = TUI(cfg.Title or "SolanaHub")
        local desc  = TUI(cfg.Description or cfg.Content or "")
        local dur   = cfg.Time or cfg.Duration or 2
        local text  = desc ~= "" and (title .. "  " .. desc) or title
        pcall(function()
            local gui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if not gui then return end
            local ng = gui:FindFirstChild("SolanaHubNotif")
            if not ng then return end
            local frame = Instance.new("Frame")
            frame.Name = "MiniNotif"; frame.BackgroundColor3 = Color3.fromRGB(20,20,28)
            frame.BackgroundTransparency = 0.15; frame.BorderSizePixel = 0
            local side = Library.NotifySide == "Left" and "Left" or "Right"
            local startPos = side == "Left" and UDim2.new(0,-270,1,-50) or UDim2.new(1,10,1,-50)
            local showPos  = side == "Left" and UDim2.new(0,10,1,-50)  or UDim2.new(1,-270,1,-50)
            frame.Size = UDim2.new(0,260,0,36); frame.Position = startPos
            frame.AnchorPoint = Vector2.new(0,1); frame.ZIndex = 99
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
            local acc = Instance.new("Frame", frame)
            acc.Size = UDim2.new(0,3,1,0); acc.BackgroundColor3 = Color3.fromRGB(220,35,55); acc.BorderSizePixel = 0
            Instance.new("UICorner", acc).CornerRadius = UDim.new(0,3)
            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1,-14,1,0); lbl.Position = UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Color3.fromRGB(220,220,220)
            lbl.TextSize = 12; lbl.Font = Enum.Font.GothamMedium
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextTruncate = Enum.TextTruncate.AtEnd; lbl.ZIndex = 100
            frame.Parent = ng
            local TS = game:GetService("TweenService")
            TS:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = showPos}):Play()
            task.delay(dur, function()
                pcall(function()
                    TS:Create(frame, TweenInfo.new(0.15), {Position = startPos, BackgroundTransparency = 1}):Play()
                    task.delay(0.2, function() pcall(function() frame:Destroy() end) end)
                end)
            end)
        end)
    end
    function Library:OnUnload(fn)
        if type(fn) == "function" then table.insert(unloadCallbacks, fn) end
    end
    function Library:SetNotifySide(side)
        self.NotifySide = side == "Left" and "Left" or "Right"
    end
    function Library:SetDPIScale(value)
        local dpi = math.clamp(tonumber(value) or 100, 50, 200)
        self.DPIScale = dpi
        pcall(function()
            local root = _window and _window.Root
            if not root then return end
            local scale = root:FindFirstChild("SolanaHubDPIScale")
            if not scale then
                scale = Instance.new("UIScale")
                scale.Name = "SolanaHubDPIScale"
                scale.Parent = root
            end
            scale.Scale = dpi / 100
        end)
    end
    function Library:SetCustomCursor(enabled)
        self.ShowCustomCursor = enabled and true or false
        pcall(function()
            if not UserInputService.MouseEnabled then return end
            local mouse = LocalPlayer:GetMouse()
            mouse.Icon = self.ShowCustomCursor and "rbxasset://textures/MouseLockedCursor.png" or ""
        end)
    end
    function Library:_syncKeybindFrame()
        pcall(function()
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            if not gui then return end
            local kg = gui:FindFirstChild("SolanaHubKeybindMenu")
            if not kg then
                kg = Instance.new("ScreenGui")
                kg.Name = "SolanaHubKeybindMenu"
                kg.ResetOnSpawn = false
                kg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                kg.Parent = gui

                local frame = Instance.new("Frame")
                frame.Name = "Panel"
                frame.BackgroundColor3 = Color3.fromRGB(20,20,28)
                frame.BackgroundTransparency = 0.12
                frame.BorderSizePixel = 0
                frame.Position = UDim2.new(0, 12, 1, -72)
                frame.Size = UDim2.new(0, 180, 0, 42)
                frame.ZIndex = 95
                frame.Parent = kg
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

                local label = Instance.new("TextLabel")
                label.Name = "MenuBind"
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamMedium
                label.TextColor3 = Color3.fromRGB(230,230,235)
                label.TextSize = 12
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Position = UDim2.new(0, 10, 0, 0)
                label.Size = UDim2.new(1, -20, 1, 0)
                label.ZIndex = 96
                label.Parent = frame
            end
            local panel = kg:FindFirstChild("Panel")
            if panel then
                panel.Visible = self.KeybindFrame.Visible == true
                local label = panel:FindFirstChild("MenuBind")
                if label then
                    label.Text = "Menu: " .. tostring((_window and _window.Keybind) or "RightControl")
                end
            end
        end)
    end
    function Library:SetKeybindMenuVisible(enabled)
        self.KeybindFrame.Visible = enabled and true or false
        self:_syncKeybindFrame()
    end

    -- Window shim (global)
    Window = {
        SetCornerRadius = function(self, v)
            local radius = math.clamp(tonumber(v) or 0, 0, 20)
            Library.CornerRadius = radius
            pcall(function()
                local root = _window and _window.Root
                if not root then return end
                for _, obj in ipairs(root:GetDescendants()) do
                    if obj:IsA("UICorner") then
                        obj.CornerRadius = UDim.new(0, radius)
                    end
                end
                local corner = root:FindFirstChildOfClass("UICorner")
                if corner then corner.CornerRadius = UDim.new(0, radius) end
            end)
        end,
    }

    ThemeManager = { SetLibrary = _noop, SetFolder = _noop, ApplyToTab = _noop }
    SaveManager = {
        SetLibrary = _noop, IgnoreThemeSettings = _noop, SetIgnoreIndexes = _noop,
        SetFolder = _noop, BuildConfigSection = _noop, LoadAutoloadConfig = _noop,
    }
end
_initLibrary()

-- Mini notif ScreenGui (global, dipakai Library:Notify)
local _notifGui = Instance.new("ScreenGui")
_notifGui.Name = "SolanaHubNotif"; _notifGui.ResetOnSpawn = false
_notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() _notifGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

-- L localization shim (global)
L = setmetatable({}, {
    __index = function(_, k)
        local r = _DICT[k]; if not r then return k end
        return r[_LANG] or r["EN"] or k
    end
})





-- ============================================
-- STATE VARIABLES
-- ============================================

local connections = {}
-- Daftarkan AC bypass connection yang dibuat di awal script
if getgenv()._NX_acBypassConn then
    table.insert(connections, getgenv()._NX_acBypassConn)
end
local mobESPInstances = {}
local playerESPInstances = {}
local structureESPInstances = {}
local flyBV, flyBG = nil, nil
local flyActive = false
local antiAFKConn = nil
local autoSprintActive = false
local killAuraConn = nil
local aimbotConn = nil  -- Aimbot connection for RenderStepped
local aimbotTarget = nil  -- Current aimbot target for visualization
local fovCircle = nil              -- [ADDED v7.3.3] FOV Circle Drawing object for Aimbot
local fovGui = nil
local fovFrame = nil
local lastShoot = 0
local lastReload = 0
local killAuraIndicatorLine   = nil  -- [ADDED v7.3.3] Kill Aura snapline to current target
local killAuraIndicatorCircle = nil  -- [ADDED v7.3.3] Kill Aura circle on current target
-- Remove Fog state managed by enableRemoveFog/disableRemoveFog
-- bringPickup state managed by startBringPickup/stopBringPickup
-- repairAura state managed by startRepairAura/stopRepairAura
local repairAuraConn = nil

local originalValues = {
    walkSpeed = nil,
}

local originalLighting = { stored = false }
local originalFog = { stored = false }

local mobOptions = { ESP = false, Chams = false, Name = false, Distance = false }
local playerESPVars = { ESP = false, Chams = false, Name = false, Distance = false, Health = false }
local structureESPVars = { ESP = false, Chams = false, Name = true, Distance = true, Color = Color3.fromRGB(0, 255, 200) }
local containerESP = {
    vars = {
        crates = { ESP = false, Chams = false, Color = Color3.fromRGB(255, 160, 0) },
        barrel = { ESP = false, Chams = false, Color = Color3.fromRGB(100, 200, 255) },
        emerald = { ESP = false, Chams = false, Color = Color3.fromRGB(0, 255, 120) }
    },
    instances = { crates = {}, barrel = {}, emerald = {} }
}
bhopActive = false  -- [ADDED v7.3] Bunny Hop state
bhopConn = nil  -- [ADDED v7.3] Bunny Hop connection
-- [REMOVED v7.3.1] No Stamina Drain - game uses hunger, not stamina
local remoteSpyEnabled = false  -- [ADDED v7.3] Remote Spy state
local remoteSpyLogs = {}  -- [ADDED v7.3] Remote call logs

local mobNames = {"Runner", "Crawler", "Riot", "Zombie", "Brute", "Spitter", "Boss"}

-- ============================================
-- GLOBAL ESP CONFIG (driven by UI sliders, shared by all ESP systems)
-- ============================================
local espConfig = {
    textSize            = 10,   -- ESP Text Size slider
    fillTransparency    = 0.4,  -- Fill Transparency slider
    outlineTransparency = 0.0,  -- Outline Transparency slider
}

-- ============================================
-- ESP PERFORMANCE THROTTLE
-- Reduces per-frame load when many ESP objects exist.
-- ============================================
local espPerf = {
    -- [OPT] Interval diperpanjang untuk hemat CPU
    itemInterval      = 1.00,  -- [UPDATED] was 0.40 | items are static, 1x/s sangat menghemat FPS
    mobInterval       = 0.20,  -- was 0.12 | mob: 5x/s cukup
    structureInterval = 0.60,  -- was 0.20 | struktur statis, 1.7x/s cukup
    playerInterval    = 0.25,  -- was 0.12 | player: 4x/s cukup
}

local function shouldUpdateESP(lastUpdate, interval)
    local now = tick()
    if (now - lastUpdate) < interval then
        return false, lastUpdate
    end
    return true, now
end

-- ============================================
-- ITEM CATEGORIES & COLOR DEFINITIONS
-- [CHANGED] Each ESP type now has its own dedicated color
-- ============================================
local espDefinitions = {
    {
        key = "Gun",
        displayName = "Gun ESP",
        icon = "crosshair",
        items = {
            "AA-12", "AK-47", "Assault Rifle", "Desert Eagle", "Double Barrel",
            "Flamethrower", "Grenade Launcher", "LMG", "MediGun", "Pistol",
            "Ray Gun", "Revolver", "Rifle", "Shotgun", "Sniper", "SVD", "Uzi"
        },
        colors = { fill = Color3.fromRGB(255, 30,  30),  outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 120, 120) },
    },
    {
        key = "Melee",
        displayName = "Melee ESP",
        icon = "swords",
        items = {
            "Bat", "Chainsaw", "Crowbar", "Fire Axe", "Hatchet", "Katana", "Knife",
            "Riot Shield", "Scythe", "Sledgehammer", "Spear", "Spiked Bat"
        },
        colors = { fill = Color3.fromRGB(255, 140,  0),  outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 200, 100) },
    },
    {
        key = "Medical",
        displayName = "Medical ESP",
        icon = "heart-pulse",
        items = {
            "Bandage", "Compound H", "Compound I", "Compound R", "Compound S", "Medkit"
        },
        colors = { fill = Color3.fromRGB(  0, 255,  80),  outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(150, 255, 150) },
    },
    {
        key = "Armor",
        displayName = "Armor ESP",
        icon = "shield",
        items = {
            "Power Armor", "Light Armor", "Medium Armor", "Heavy Armor"
        },
        colors = { fill = Color3.fromRGB(  0, 100, 255),  outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(160, 200, 255) },
    },
    {
        key = "Food",
        displayName = "Food ESP",
        icon = "utensils",
        items = {
            "Chips", "Carrot", "Bloxiade", "Beans", "MRE", "Bloxy Cola"
        },
        colors = { fill = Color3.fromRGB(190, 255,   0),  outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(210, 255, 150) },
    },
    {
        key = "Resource",
        displayName = "Resources ESP",
        icon = "box",
        items = {
            "AC", "Battery", "Battery Pack", "Bucket", "Dumbell", "Exhaust Pipe",
            "Reactor Component", "Refined Metal", "Satellite Dish", "Scrap",
            "Screws", "Spatula", "Tray", "TV", "Watch", "Zombie Heart"
        },
        colors = { fill = Color3.fromRGB(  0, 220, 255),  outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(180, 240, 255) },
    },
    {
        key = "Fuel",
        displayName = "Fuel ESP",
        icon = "zap",
        items = { "Nuclear Fuel", "Refined Fuel", "Fuel" },
        colors = { fill = Color3.fromRGB(255, 220,   0),  outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(255, 240, 160) },
    },
    {
        key = "Ability",
        displayName = "Abilities ESP",
        icon = "zap-circle",
        items = {
            "Airstrike", "Attack Order", "Call of the Dead",
            "Summon Brute", "Summon Zombies", "Taunt",
            "The Future", "The Past", "The Present"
        },
        colors = { fill = Color3.fromRGB(180,  0, 255),  outline = Color3.fromRGB(255, 255, 255), text = Color3.fromRGB(220, 150, 255) },
    },
}

-- Build per-ESP state tables, instance tables, and item lookups
local espSystems = {} -- Master table holding all ESP system data and functions

for _, def in ipairs(espDefinitions) do
    local sys = {
        key = def.key,
        displayName = def.displayName,
        colors = def.colors,
        items = def.items,
        itemList = {}, -- fast lookup set
        vars = { ESP = false, Chams = false, Name = false, Distance = false },
        instances = {},
        listenersSetup = false,
    }
    for _, name in ipairs(def.items) do
        sys.itemList[name] = true
    end
    espSystems[def.key] = sys
end

-- Build flat itemNames from all ESP categories (used for BringPickupItem filter)
local itemNames = {}
local itemCategoryLookup = {}
for _, def in ipairs(espDefinitions) do
    for _, itemName in ipairs(def.items) do
        table.insert(itemNames, itemName)
        itemCategoryLookup[itemName] = def.key
    end
end
-- Add extra categories not covered by dedicated ESP (still usable in BringPickupItem / Teleport)
local extraItemCategories = {
    Ammo = { "Ammo Box", "Long Ammo", "Medium Ammo", "Pistol Ammo", "Shells" },
    Structures = {
        "Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
        "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map",
        "Repair Drone", "Shelf", "Teleporter", "Time Machine", "Turret",
        "Wall", "Watchtower"
    },
    Consumables = { "Grenade", "Molotov" },
    Backpacks = { "Basic Backpack", "Good Backpack", "Great Backpack" },
    MiscItems = {
        "Emerald", "Gas Mask", "Power Armor Arm", "Power Armor Core",
        "Radio Tower Part", "Blueprint", "Military Keycard", "Repair Hammer", "Suppressor"
    },
}
for catName, catItems in pairs(extraItemCategories) do
    for _, itemName in ipairs(catItems) do
        table.insert(itemNames, itemName)
        itemCategoryLookup[itemName] = catName
    end
end
table.sort(itemNames)
table.insert(itemNames, 1, "All")

-- Bring Pickup Item set (E-key: Guns, Melee, Medical, Armor, Ammo, Structures, Tools)
local pickupItemSet = {
    ["Ammo Box"]=true,["Long Ammo"]=true,["Medium Ammo"]=true,["Shells"]=true,["Pistol Ammo"]=true,
    ["Power Armor"]=true,["Light Armor"]=true,["Medium Armor"]=true,["Heavy Armor"]=true,
    ["Emerald"]=true,["Gas Mask"]=true,
    ["Ammo Crate"]=true,["Barbed Wire"]=true,["Bear Trap"]=true,["Boost Pad"]=true,
    ["Electric Fence"]=true,["Farm Plot"]=true,["Fence"]=true,["Floodlight"]=true,
    ["Gate"]=true,["Landmine"]=true,["Map"]=true,["Repair Drone"]=true,["Shelf"]=true,
    ["Teleporter"]=true,["Time Machine"]=true,["Turret"]=true,["Wall"]=true,["Watchtower"]=true,
    ["Basic Backpack"]=true,["Good Backpack"]=true,["Great Backpack"]=true,
    ["Grenade"]=true,["Molotov"]=true,
    ["AA-12"]=true,["AK-47"]=true,["Assault Rifle"]=true,["Desert Eagle"]=true,
    ["Double Barrel"]=true,["Flamethrower"]=true,["Grenade Launcher"]=true,["LMG"]=true,
    ["MediGun"]=true,["Pistol"]=true,["Ray Gun"]=true,["Revolver"]=true,["Rifle"]=true,
    ["Shotgun"]=true,["Sniper"]=true,["SVD"]=true,["Uzi"]=true,
    ["Bandage"]=true,["Compound H"]=true,["Compound I"]=true,["Compound R"]=true,
    ["Compound S"]=true,["Medkit"]=true,
    ["Bat"]=true,["Chainsaw"]=true,["Crowbar"]=true,["Fire Axe"]=true,["Hatchet"]=true,
    ["Katana"]=true,["Knife"]=true,["Riot Shield"]=true,["Scythe"]=true,
    ["Sledgehammer"]=true,["Spear"]=true,["Spiked Bat"]=true,
    ["Blueprint"]=true,["Military Keycard"]=true,["Repair Hammer"]=true,["Suppressor"]=true,
}
local pickupItemNames = {}
for k in pairs(pickupItemSet) do table.insert(pickupItemNames, k) end
table.sort(pickupItemNames)

local structureNames = {
    "Ammo Crate", "Barbed Wire", "Bear Trap", "Boost Pad", "Electric Fence",
    "Farm Plot", "Fence", "Floodlight", "Gate", "Landmine", "Map", "Repair Drone",
    "Shelf", "Teleporter", "Time Machine", "Turret", "Wall", "Watchtower"
}

-- ============================================
-- DYNAMIC FOLDER DISCOVERY
-- ============================================
local charactersFolder
local droppedItemsFolder
local structuresFolder
local mobListenersSetup = false
local refreshMobESP, refreshPlayerESP, refreshStructureESP
local removeMobESP, removePlayerESP, removeStructureESP
local createPlayerESP
local getItemMainPart
local getItemPickupPosition
local getDroppedItemRoot
local setAllESPNames, setAllESPDistance
local applyESPTextSize, applyESPTransparency
local startFly, stopFly
local enableFullbright, disableFullbright
local startAutoSprint, stopAutoSprint
local startAntiAFK, stopAntiAFK
local startKillAura, stopKillAura
local enableRemoveFog, disableRemoveFog
local startBhop, stopBhop
local startFunnyDance, stopFunnyDance
local serverHop, rejoinServer
local startRemoteSpy, stopRemoteSpy
local startAutoPickup, stopAutoPickup
local startRepairAura, stopRepairAura
local startAutoFarmEngine, stopAutoFarmEngine
local startAutoFarmGem, stopAutoFarmGem
local applyClassAvatar, resetToOriginalAvatar

local function _initESP()

local function discoverFolders()
    charactersFolder = Workspace:FindFirstChild("Characters")
    droppedItemsFolder = Workspace:FindFirstChild("DroppedItems")
    structuresFolder = Workspace:FindFirstChild("Structures")
        or Workspace:FindFirstChild("PlayerStructures")
        or Workspace:FindFirstChild("Buildings")
end
discoverFolders()

task.spawn(function()
    while not Library.Unloaded do
        task.wait(5)
        local prevChars = charactersFolder
        local prevItems = droppedItemsFolder
        local prevStructs = structuresFolder
        discoverFolders()
        if charactersFolder ~= prevChars and charactersFolder then
            refreshMobESP()
            if not mobListenersSetup then setupMobListeners() end
        end
        if droppedItemsFolder ~= prevItems and droppedItemsFolder then
            for _, sys in pairs(espSystems) do
                sys.refresh()
            end
            for _, sys in pairs(espSystems) do
                if not sys.listenersSetup then sys.setupListeners() end
            end
        end
        if structuresFolder ~= prevStructs and structuresFolder then
            refreshStructureESP()
            if not structureListenersSetup then setupStructureListeners() end
        end
    end
end)

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
getItemMainPart = function(item)
    if not item then return nil end
    if item and item:IsA("BasePart") then return item end
    if item:IsA("Model") and item.PrimaryPart then return item.PrimaryPart end
    for _, child in ipairs(item:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return item:FindFirstChildWhichIsA("BasePart", true)
end

getItemPickupPosition = function(item)
    if not item then return nil end
    local part = getItemMainPart(item)
    if part then return part.Position, part end

    if item:IsA("Model") then
        local ok, cf = pcall(function()
            local boxCF = item:GetBoundingBox()
            return boxCF
        end)
        if ok and cf then return cf.Position, nil end
    end

    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
    local promptParent = prompt and prompt.Parent
    if promptParent and promptParent:IsA("BasePart") then
        return promptParent.Position, promptParent
    end

    return nil
end

getDroppedItemRoot = function(inst)
    if not inst or not droppedItemsFolder then return inst end
    local current = inst
    while current and current.Parent and current.Parent ~= droppedItemsFolder do
        current = current.Parent
    end
    if current and current.Parent == droppedItemsFolder then
        return current
    end
    return inst
end

-- ============================================
-- SHARED ESP HELPERS
-- ============================================
local function getDistanceColor(dist)
    if dist > 250 then return Color3.fromRGB(255, 80, 80)
    elseif dist > 150 then return Color3.fromRGB(255, 180, 80)
    elseif dist > 100 then return Color3.fromRGB(255, 255, 80)
    else return Color3.fromRGB(220, 220, 220) end
end

local function getHealthColor(pct)
    if pct > 0.6 then return Color3.fromRGB(80, 255, 80)
    elseif pct > 0.3 then return Color3.fromRGB(255, 230, 50)
    else return Color3.fromRGB(255, 60, 60) end
end

local function createHealthBar(parent, height, width, position)
    local bg = Instance.new("Frame")
    bg.Name = "HealthBarBG"
    bg.Size = UDim2.new(width, 0, height, 0)
    bg.Position = position
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    bg.BackgroundTransparency = 0.2
    bg.BorderSizePixel = 0
    bg.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = bg

    local fill = Instance.new("Frame")
    fill.Name = "HealthBarFill"
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    fill.BorderSizePixel = 0
    fill.Parent = bg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    return bg, fill
end

local function updateHealthBar(fill, pct, color)
    fill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = color
end

local function createTextBG(parent, size, position)
    local bg = Instance.new("Frame")
    bg.Name = "TextBG"
    bg.Size = size
    bg.Position = position
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.BorderSizePixel = 0
    bg.ZIndex = -1
    bg.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = bg
    return bg
end

local MOB_RED = { fill = Color3.fromRGB(255, 30, 30), outline = Color3.fromRGB(255, 120, 120) }
local mobTypeColors = {
    Zombie  = MOB_RED, Runner  = MOB_RED, Crawler = MOB_RED,
    Brute   = MOB_RED, Spitter = MOB_RED, Riot    = MOB_RED, Boss = MOB_RED,
}

-- ============================================
-- GENERIC ITEM ESP FACTORY
-- [ADDED] Creates create/remove/refresh/setupListeners functions per ESP system
-- This eliminates code duplication across all 6 category ESPs
-- ============================================
local function createCategoryESP(sys, item)
    if not item:IsA("Model") then return end
    if sys.instances[item] then return end

    local mainPart = getItemMainPart(item)
    if not mainPart then return end

    -- MainPart stored at top level so the always-on connection can access it
    local espTable = { MainPart = mainPart }

    if sys.vars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = sys.key .. "ESP_Highlight"
        highlight.Adornee = item
        highlight.FillColor = sys.colors.fill
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = sys.colors.outline
        highlight.OutlineTransparency = espConfig.outlineTransparency
        highlight.Parent = item
        espTable.Highlight = highlight
    end

    if sys.vars.Name or sys.vars.Distance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = sys.key .. "ESP_NameDistance"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 220, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = item

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "[" .. sys.key .. "] " .. item.Name
        nameLabel.TextColor3 = sys.colors.text
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Visible = sys.vars.Name
        nameLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = sys.vars.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
    end

    espTable.MainPart = mainPart

    sys.instances[item] = espTable
end

local function removeCategoryESP(sys, item)
    local esp = sys.instances[item]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        -- esp.DistanceConnection removed
        sys.instances[item] = nil
    end
end

local function refreshCategoryESP(sys)
    for item, _ in pairs(sys.instances) do
        removeCategoryESP(sys, item)
    end
    if not sys.vars.ESP then return end
    if not droppedItemsFolder then return end
    for _, child in ipairs(droppedItemsFolder:GetChildren()) do
        if sys.itemList[child.Name] then
            createCategoryESP(sys, child)
        end
    end
end

local function setupCategoryListeners(sys)
    if not droppedItemsFolder or sys.listenersSetup then return end
    sys.listenersSetup = true
    local addedConn = droppedItemsFolder.ChildAdded:Connect(function(child)
        if sys.vars.ESP and sys.itemList[child.Name] then
            task.wait(0.2)  -- [FIX] Wait for item model/PrimaryPart to replicate
            createCategoryESP(sys, child)
        end
    end)
    table.insert(connections, addedConn)
    local removedConn = droppedItemsFolder.ChildRemoved:Connect(function(child)
        removeCategoryESP(sys, child)
    end)
    table.insert(connections, removedConn)
end

-- Wire up factory functions to each ESP system
for _, sys in pairs(espSystems) do
    sys.create = function(item) createCategoryESP(sys, item) end
    sys.remove = function(item) removeCategoryESP(sys, item) end
    sys.refresh = function() refreshCategoryESP(sys) end
    sys.setupListeners = function() setupCategoryListeners(sys) end
end

-- Set up all category listeners immediately (will also retry on folder discovery)
for _, sys in pairs(espSystems) do
    setupCategoryListeners(sys)
end

-- ============================================
-- MOB ESP FUNCTIONS
-- ============================================
removeMobESP = function(char)
    local esp = mobESPInstances[char]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        -- esp.DistanceConnection removed
        mobESPInstances[char] = nil
    end
end

local function createMobESP(char)
    if not char:IsA("Model") then return end
    if mobESPInstances[char] then return end

    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root then return end

    local espTable = { Root = root }
    local mobColors = mobTypeColors[char.Name] or {fill = Color3.fromRGB(220, 0, 0), outline = Color3.fromRGB(255, 185, 185)}

    if mobOptions.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MobESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = mobColors.fill
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = mobColors.outline
        highlight.OutlineTransparency = espConfig.outlineTransparency
        highlight.Parent = char
        espTable.Highlight = highlight
    end

    -- Hoist billboard vars so always-on connection can access them
    local billboard, nameLabel, distLabel
    if mobOptions.Name or mobOptions.Distance then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "MobESP_NameDistance"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 220, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = char.Name
        nameLabel.TextColor3 = mobColors.outline
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Visible = mobOptions.Name
        nameLabel.Parent = frame

        distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = mobOptions.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
    end

    -- Pre-calculated root assigned to table

    mobESPInstances[char] = espTable
end

refreshMobESP = function()
    for char, _ in pairs(mobESPInstances) do
        removeMobESP(char)
    end
    if not mobOptions.ESP then return end
    if not charactersFolder then
        Library:Notify({ Title = "Mob ESP", Description = "Characters folder not found (retrying...)", Time = 3 })
        return
    end
    -- Build player char set to exclude real players (same logic as Kill Aura)
    local playerCharSet = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then playerCharSet[p.Character] = true end
    end
    for _, child in ipairs(charactersFolder:GetChildren()) do
        if child:IsA("Model") and not playerCharSet[child] then
            createMobESP(child)
        end
    end
end

-- ============================================
-- STRUCTURE ESP FUNCTIONS
-- ============================================
removeStructureESP = function(structure)
    local esp = structureESPInstances[structure]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        -- esp.DistanceConnection removed
        structureESPInstances[structure] = nil
    end
end

local function createStructureESP(structure)
    if not structure:IsA("Model") then return end
    if structureESPInstances[structure] then return end

    local mainPart = structure.PrimaryPart or getItemMainPart(structure)
    if not mainPart then return end

    local espTable = { MainPart = mainPart }

    if structureESPVars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "StructESP_Highlight"
        highlight.Adornee = structure
        highlight.FillColor = Color3.fromRGB(0, 200, 150)
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = Color3.fromRGB(100, 255, 200)
        highlight.OutlineTransparency = espConfig.outlineTransparency
        highlight.Parent = structure
        espTable.Highlight = highlight
    end

    local billboard, nameLabel, distLabel
    if structureESPVars.Name or structureESPVars.Distance then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "StructESP_Info"
        billboard.Adornee = mainPart
        billboard.Size = UDim2.new(0, 250, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = structure

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "[STRUCTURE] " .. structure.Name
        nameLabel.TextColor3 = structureESPVars.Color
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Visible = structureESPVars.Name
        nameLabel.Parent = frame

        distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(200, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = structureESPVars.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
    end

    -- Pre-calculated mainPart assigned to table

    structureESPInstances[structure] = espTable
end

refreshStructureESP = function()
    for structure, _ in pairs(structureESPInstances) do
        removeStructureESP(structure)
    end
    if not structureESPVars.ESP then return end
    if not structuresFolder then
        Library:Notify({ Title = "Structure ESP", Description = "Structures folder not found (retrying...)", Time = 3 })
        return
    end
    for _, child in ipairs(structuresFolder:GetDescendants()) do
        if child:IsA("Model") and table.find(structureNames, child.Name) then
            createStructureESP(child)
        end
    end
end

-- ============================================
-- CONTAINER ESP (Crates / Barrel / Emerald)
-- ============================================
containerESP.make = function(obj, espVars, instanceTable, nameText)
    if instanceTable[obj] then return end
    
    local espTable = {}
    local mainPart = obj:IsA("BasePart") and obj
        or (obj.PrimaryPart)
        or obj:FindFirstChildWhichIsA("BasePart", true)
    if not mainPart then return end
    espTable.MainPart = mainPart

    if espVars.Chams then
        local hl = Instance.new("Highlight")
        hl.Name = "ContainerESP_Highlight"
        hl.Adornee = obj
        hl.FillColor = espVars.Color
        hl.FillTransparency = espConfig.fillTransparency
        hl.OutlineColor = espVars.Color
        hl.OutlineTransparency = espConfig.outlineTransparency
        hl.Parent = obj
        espTable.Highlight = hl
    end

    if espVars.ESP then
        local bb = Instance.new("BillboardGui")
        bb.Name = "ContainerESP_Billboard"
        bb.Adornee = mainPart
        bb.Size = UDim2.new(0, 200, 0, 40)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Parent = obj

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = bb

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = nameText or obj.Name
        nameLabel.TextColor3 = espVars.Color
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Parent = frame

        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(200, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Parent = frame

        espTable.Billboard = bb
        espTable.NameLabel = nameLabel
        espTable.DistLabel = distLabel
    end

    instanceTable[obj] = espTable
end

containerESP.remove = function(obj, instanceTable)
    local esp = instanceTable[obj]
    if esp then
        pcall(function() if esp.Highlight then esp.Highlight:Destroy() end end)
        pcall(function() if esp.Billboard then esp.Billboard:Destroy() end end)
        if esp.DistConn then esp.DistConn:Disconnect() end
        instanceTable[obj] = nil
    end
end

containerESP.refresh = function(espVars, instanceTable, folderPath, label)
    for obj in pairs(instanceTable) do containerESP.remove(obj, instanceTable) end
    if not espVars.ESP and not espVars.Chams then return end
    pcall(function()
        local folder = folderPath()
        if not folder then
            Library:Notify({ Title = label .. " ESP", Description = "Path not found", Time = 3 })
            return
        end
        local function isValidContainer(child)
            if child:IsA("Model") then return true end
            if child:IsA("BasePart") then
                local n = string.lower(child.Name)
                if n == "mainpart" or n == "barrel" or n == "crate" or n == "emerald" then
                    return true
                end
            end
            return false
        end

        for _, child in ipairs(folder:GetChildren()) do
            if isValidContainer(child) then
                containerESP.make(child, espVars, instanceTable, label)
            end
        end
        folder.ChildAdded:Connect(function(child)
            if (espVars.ESP or espVars.Chams) and isValidContainer(child) then
                task.wait(0.1)
                containerESP.make(child, espVars, instanceTable, label)
            end
        end)
        folder.ChildRemoved:Connect(function(child)
            containerESP.remove(child, instanceTable)
        end)
    end)
end

-- Crates
containerESP.refreshCrates = function()
    containerESP.refresh(containerESP.vars.crates, containerESP.instances.crates, function()
        local m = Workspace:FindFirstChild("Map")
        local c = m and m:FindFirstChild("Crates")
        return c and c:FindFirstChild("Default")
    end, "Crates")
end

-- Barrel
containerESP.refreshBarrel = function()
    containerESP.refresh(containerESP.vars.barrel, containerESP.instances.barrel, function()
        local s = Workspace:FindFirstChild("Structures")
        return s and s:FindFirstChild("Barrel")
    end, "Barrel")
end

-- Emerald Crates
containerESP.refreshEmerald = function()
    containerESP.refresh(containerESP.vars.emerald, containerESP.instances.emerald, function()
        local m = Workspace:FindFirstChild("Map")
        local c = m and m:FindFirstChild("Crates")
        return c and c:FindFirstChild("Emerald")
    end, "Emerald Crates")
end

-- ============================================
-- PLAYER ESP FUNCTIONS
-- ============================================
removePlayerESP = function(player)
    local esp = playerESPInstances[player]
    if esp then
        if esp.Highlight then esp.Highlight:Destroy() end
        if esp.Billboard then esp.Billboard:Destroy() end
        -- esp.DistanceConnection removed
        if esp.CharAddedConn then esp.CharAddedConn:Disconnect() end
        playerESPInstances[player] = nil
    end
end

createPlayerESP = function(player)
    if player == LocalPlayer then return end
    if playerESPInstances[player] then return end

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local espTable = {}

    if playerESPVars.Chams then
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP_Highlight"
        highlight.Adornee = char
        highlight.FillColor = Color3.fromRGB(0, 100, 255)
        highlight.FillTransparency = espConfig.fillTransparency
        highlight.OutlineColor = Color3.fromRGB(100, 180, 255)
        highlight.OutlineTransparency = espConfig.outlineTransparency
        highlight.Parent = char
        espTable.Highlight = highlight
    end

    -- Hoist so always-on connection can reference them after the block
    local billboard, nameLabel, toolLabel, healthLabel, distLabel
    if playerESPVars.Name or playerESPVars.Distance or playerESPVars.Health then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "PlayerESP_Info"
        billboard.Adornee = root
        billboard.Size = UDim2.new(0, 220, 0, 70)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = billboard

        nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        nameLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        nameLabel.TextStrokeTransparency = 0.2
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = espConfig.textSize
        nameLabel.Visible = playerESPVars.Name
        nameLabel.Parent = frame

        toolLabel = Instance.new("TextLabel")
        toolLabel.Name = "ToolLabel"
        toolLabel.Size = UDim2.new(1, 0, 0.25, 0)
        toolLabel.Position = UDim2.new(0, 0, 0.3, 0)
        toolLabel.BackgroundTransparency = 1
        toolLabel.Text = ""
        toolLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
        toolLabel.TextStrokeTransparency = 0.2
        toolLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        toolLabel.Font = Enum.Font.Gotham
        toolLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        toolLabel.Visible = playerESPVars.Name
        toolLabel.Parent = frame

        healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "HealthLabel"
        healthLabel.Size = UDim2.new(1, 0, 0.2, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.55, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.Text = "100 HP"
        healthLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        healthLabel.TextStrokeTransparency = 0.2
        healthLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        healthLabel.Font = Enum.Font.GothamBold
        healthLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        healthLabel.Visible = playerESPVars.Health
        healthLabel.Parent = frame

        distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.2, 0)
        distLabel.Position = UDim2.new(0, 0, 0.78, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0m"
        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        distLabel.TextStrokeTransparency = 0.2
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = math.max(espConfig.textSize - 2, 8)
        distLabel.Visible = playerESPVars.Distance
        distLabel.Parent = frame

        espTable.Billboard = billboard
        espTable.NameLabel = nameLabel
        espTable.ToolLabel = toolLabel
        espTable.HealthLabel = healthLabel
        espTable.DistLabel = distLabel
    end

    -- Pre-calculated connections setup

    local charAddedConn = player.CharacterAdded:Connect(function()
        if playerESPVars.ESP then
            task.wait(1)
            removePlayerESP(player)
            createPlayerESP(player)
        end
    end)
    espTable.CharAddedConn = charAddedConn
    table.insert(connections, charAddedConn)

    playerESPInstances[player] = espTable
end

refreshPlayerESP = function()
    for player, _ in pairs(playerESPInstances) do
        removePlayerESP(player)
    end
    if not playerESPVars.ESP then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                createPlayerESP(player)
            else
                local conn
                conn = player.CharacterAdded:Connect(function()
                    if conn then conn:Disconnect() end
                    if playerESPVars.ESP then
                        task.wait(1)
                        createPlayerESP(player)
                    end
                end)
                table.insert(connections, conn)
            end
        end
    end
end

-- ============================================
-- FOLDER EVENT LISTENERS
-- ============================================
local function setupMobListeners()
    if not charactersFolder or mobListenersSetup then return end
    mobListenersSetup = true
    local childAddedConn = charactersFolder.ChildAdded:Connect(function(child)
        if mobOptions.ESP and child:IsA("Model") then
            -- Exclude real player characters
            local playerCharSet = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then playerCharSet[p.Character] = true end
            end
            if not playerCharSet[child] then
                task.wait(0.2)  -- [FIX] Wait for HumanoidRootPart to replicate
                createMobESP(child)
            end
        end
    end)
    table.insert(connections, childAddedConn)

    local childRemovedConn = charactersFolder.ChildRemoved:Connect(function(child)
        removeMobESP(child)
    end)
    table.insert(connections, childRemovedConn)
end
setupMobListeners()

local function setupStructureListeners()
    if not structuresFolder or structureListenersSetup then return end
    structureListenersSetup = true
    local descendantAddedConn = structuresFolder.DescendantAdded:Connect(function(child)
        if structureESPVars.ESP and child:IsA("Model") and table.find(structureNames, child.Name) then
            task.wait(0.2)  -- [FIX] Wait for PrimaryPart to replicate
            createStructureESP(child)
        end
    end)
    table.insert(connections, descendantAddedConn)

    local descendantRemovingConn = structuresFolder.DescendantRemoving:Connect(function(child)
        removeStructureESP(child)
    end)
    table.insert(connections, descendantRemovingConn)
end
setupStructureListeners()

-- ============================================
-- CENTRALIZED THROTTLED ESP MANAGER
-- ============================================
local lastESPUpdate = 0
local espUpdateInterval = 0.12  -- Updates 8 times per second. Very fast, uses ~0% CPU.
local espHeartbeatConn

espHeartbeatConn = RunService.Heartbeat:Connect(function()
    local now = tick()
    if (now - lastESPUpdate) < espUpdateInterval then return end
    lastESPUpdate = now

    local myChar = LocalPlayer.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso"))
    if not myRoot then return end
    local myPos = myRoot.Position
    local maxDist = Options and Options.ESPMaxDistance and Options.ESPMaxDistance.Value or 99999

    -- 1. Category (Item) ESP Update Loop
    for _, sys in pairs(espSystems) do
        if sys.vars.ESP then
            for item, espTable in pairs(sys.instances) do
                if not item or not item.Parent then
                    -- Cleanup orphaned ESP entries
                    if espTable.Billboard then pcall(function() espTable.Billboard:Destroy() end) end
                    if espTable.Highlight then pcall(function() espTable.Highlight:Destroy() end) end
                    sys.instances[item] = nil
                else
                    local mainPart = espTable.MainPart or (item:IsA("BasePart") and item or item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true))
                    if mainPart then
                        espTable.MainPart = mainPart

                        -- Hide ESP for opened/transparent items
                        local isTransparent = item:IsA("BasePart") and item.Transparency >= 1
                        local dist = (myPos - mainPart.Position).Magnitude
                        local visible = (not isTransparent) and dist <= maxDist

                        -- Highlight (Chams)
                        if sys.vars.Chams then
                            if not espTable.Highlight or not espTable.Highlight.Parent then
                                local h = Instance.new("Highlight")
                                h.Name = sys.key .. "ESP_Highlight"
                                h.Adornee = item
                                h.FillColor = sys.colors.fill
                                h.FillTransparency = espConfig.fillTransparency
                                h.OutlineColor = sys.colors.outline
                                h.OutlineTransparency = espConfig.outlineTransparency
                                h.Enabled = visible
                                h.Parent = item
                                espTable.Highlight = h
                            else
                                if espTable.Highlight.Enabled ~= visible then
                                    espTable.Highlight.Enabled = visible
                                end
                            end
                        elseif espTable.Highlight then
                            if espTable.Highlight.Enabled ~= false then
                                espTable.Highlight.Enabled = false
                            end
                        end

                        -- Billboard
                        if espTable.Billboard and espTable.Billboard.Parent then
                            if espTable.Billboard.Enabled ~= visible then
                                espTable.Billboard.Enabled = visible
                            end
                            if visible and espTable.DistLabel and sys.vars.Distance then
                                local roundedDist = math.floor(dist)
                                if espTable.LastDist ~= roundedDist then
                                    espTable.LastDist = roundedDist
                                    espTable.DistLabel.Text = roundedDist .. "m"
                                    espTable.DistLabel.TextColor3 = getDistanceColor(dist)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. Mob ESP Update Loop
    if mobOptions.ESP then
        for char, espTable in pairs(mobESPInstances) do
            if char and char.Parent then
                local root = espTable.Root or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                if root then
                    espTable.Root = root
                    local dist = (myPos - root.Position).Magnitude
                    local visible = dist <= maxDist
                    local mc = mobTypeColors[char.Name] or {fill = Color3.fromRGB(220, 0, 0), outline = Color3.fromRGB(255, 185, 185)}

                    -- Highlight (Chams)
                    if mobOptions.Chams then
                        if not espTable.Highlight or not espTable.Highlight.Parent then
                            local h = Instance.new("Highlight")
                            h.Name = "MobESP_Highlight"
                            h.Adornee = char
                            h.FillColor = mc.fill
                            h.FillTransparency = espConfig.fillTransparency
                            h.OutlineColor = mc.outline
                            h.OutlineTransparency = espConfig.outlineTransparency
                            h.Enabled = visible
                            h.Parent = char
                            espTable.Highlight = h
                        else
                            if espTable.Highlight.Enabled ~= visible then
                                espTable.Highlight.Enabled = visible
                            end
                        end
                    elseif espTable.Highlight then
                        if espTable.Highlight.Enabled ~= false then
                            espTable.Highlight.Enabled = false
                        end
                    end

                    -- Billboard
                    if espTable.Billboard and espTable.Billboard.Parent then
                        if espTable.Billboard.Enabled ~= visible then
                            espTable.Billboard.Enabled = visible
                        end
                        if visible then
                            if espTable.NameLabel and mobOptions.Name then
                                local hum = espTable.Humanoid or char:FindFirstChildOfClass("Humanoid")
                                if hum then
                                    espTable.Humanoid = hum
                                    local roundedHp = math.floor(hum.Health)
                                    local roundedMax = math.floor(hum.MaxHealth)
                                    local hpKey = roundedHp .. "/" .. roundedMax
                                    if espTable.LastHpText ~= hpKey then
                                        espTable.LastHpText = hpKey
                                        espTable.NameLabel.Text = char.Name .. " [" .. hpKey .. "]"
                                    end
                                end
                            end
                            if espTable.DistLabel and mobOptions.Distance then
                                local roundedDist = math.floor(dist)
                                if espTable.LastDist ~= roundedDist then
                                    espTable.LastDist = roundedDist
                                    espTable.DistLabel.Text = roundedDist .. "m"
                                    espTable.DistLabel.TextColor3 = getDistanceColor(dist)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- 3. Structure ESP Update Loop
    if structureESPVars.ESP then
        for structure, espTable in pairs(structureESPInstances) do
            if structure and structure.Parent then
                local root = espTable.Root or structure.PrimaryPart or structure:FindFirstChildWhichIsA("BasePart", true)
                if root then
                    espTable.Root = root
                    local dist = (myPos - root.Position).Magnitude
                    local visible = dist <= maxDist

                    -- Highlight (Chams)
                    if structureESPVars.Chams then
                        if not espTable.Highlight or not espTable.Highlight.Parent then
                            local h = Instance.new("Highlight")
                            h.Name = "StructESP_Highlight"
                            h.Adornee = structure
                            h.FillColor = Color3.fromRGB(0, 200, 150)
                            h.FillTransparency = espConfig.fillTransparency
                            h.OutlineColor = Color3.fromRGB(100, 255, 200)
                            h.OutlineTransparency = espConfig.outlineTransparency
                            h.Enabled = visible
                            h.Parent = structure
                            espTable.Highlight = h
                        else
                            if espTable.Highlight.Enabled ~= visible then
                                espTable.Highlight.Enabled = visible
                            end
                        end
                    elseif espTable.Highlight then
                        if espTable.Highlight.Enabled ~= false then
                            espTable.Highlight.Enabled = false
                        end
                    end

                    -- Billboard
                    if espTable.Billboard and espTable.Billboard.Parent then
                        if espTable.Billboard.Enabled ~= visible then
                            espTable.Billboard.Enabled = visible
                        end
                        if visible and espTable.DistLabel and structureESPVars.Distance then
                            local roundedDist = math.floor(dist)
                            if espTable.LastDist ~= roundedDist then
                                espTable.LastDist = roundedDist
                                espTable.DistLabel.Text = roundedDist .. "m"
                                espTable.DistLabel.TextColor3 = getDistanceColor(dist)
                            end
                        end
                    end
                end
            end
        end
    end

    -- 4. Player ESP Update Loop
    if playerESPVars.ESP then
        for player, espTable in pairs(playerESPInstances) do
            if player and player.Parent and player.Character and player.Character.Parent then
                local char = player.Character
                local root = espTable.Root or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                if root then
                    espTable.Root = root
                    local dist = (myPos - root.Position).Magnitude
                    local visible = dist <= maxDist

                    -- Highlight (Chams)
                    if playerESPVars.Chams then
                        if not espTable.Highlight or not espTable.Highlight.Parent then
                            local h = Instance.new("Highlight")
                            h.Name = "PlayerESP_Highlight"
                            h.Adornee = char
                            h.FillColor = Color3.fromRGB(0, 100, 255)
                            h.FillTransparency = espConfig.fillTransparency
                            h.OutlineColor = Color3.fromRGB(100, 180, 255)
                            h.OutlineTransparency = espConfig.outlineTransparency
                            h.Enabled = visible
                            h.Parent = char
                            espTable.Highlight = h
                        else
                            if espTable.Highlight.Enabled ~= visible then
                                espTable.Highlight.Enabled = visible
                            end
                        end
                    elseif espTable.Highlight then
                        if espTable.Highlight.Enabled ~= false then
                            espTable.Highlight.Enabled = false
                        end
                    end

                    -- Billboard
                    if espTable.Billboard and espTable.Billboard.Parent then
                        if espTable.Billboard.Enabled ~= visible then
                            espTable.Billboard.Enabled = visible
                        end
                        if visible then
                            local hum = espTable.Humanoid or char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                espTable.Humanoid = hum
                                local roundedHp = math.floor(hum.Health)
                                local roundedMax = math.floor(hum.MaxHealth)
                                local hpKey = roundedHp .. "/" .. roundedMax
                                
                                if espTable.NameLabel and playerESPVars.Name then
                                    if espTable.LastHpTextName ~= hpKey then
                                        espTable.LastHpTextName = hpKey
                                        espTable.NameLabel.Text = player.DisplayName .. " [" .. hpKey .. "]"
                                    end
                                end
                                if espTable.HealthLabel and playerESPVars.Health then
                                    if espTable.LastHpTextHealth ~= hpKey then
                                        espTable.LastHpTextHealth = hpKey
                                        espTable.HealthLabel.Text = roundedHp .. " HP"
                                        espTable.HealthLabel.TextColor3 = getHealthColor(hum.Health / hum.MaxHealth)
                                    end
                                end
                            end
                            if espTable.ToolLabel and playerESPVars.Name then
                                -- Check tool equipped (throttle tool search using tick)
                                local lastToolCheck = espTable.LastToolCheck or 0
                                if now - lastToolCheck >= 1.0 then
                                    espTable.LastToolCheck = now
                                    local tool = char:FindFirstChildOfClass("Tool")
                                    local toolName = tool and ("[ " .. tool.Name .. " ]") or ""
                                    if espTable.LastToolName ~= toolName then
                                        espTable.LastToolName = toolName
                                        espTable.ToolLabel.Text = toolName
                                    end
                                end
                            end
                            if espTable.DistLabel and playerESPVars.Distance then
                                local roundedDist = math.floor(dist)
                                if espTable.LastDist ~= roundedDist then
                                    espTable.LastDist = roundedDist
                                    espTable.DistLabel.Text = roundedDist .. "m"
                                    espTable.DistLabel.TextColor3 = getDistanceColor(dist)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)
table.insert(connections, espHeartbeatConn)

end
_initESP()

local function _initMovement()

-- ============================================
-- SPEED HACK PERSISTENCE (FE BYPASS)
-- ============================================
-- [FIX v1.7.9] SpeedHack dikelola sepenuhnya oleh startSpeedHack()/stopSpeedHack()
-- di Player Tab (menggunakan BodyVelocity SOLANA HUB_SPEED_BV).
-- Global loop duplikat dihapus untuk menghindari double-BodyVelocity conflict.

-- ============================================
-- NOCLIP (FE Bypass  -  prevents server rubber-band correction)
-- Heartbeat fires before physics simulation, so CanCollide = false takes effect
-- before the engine resolves collisions. Anti-rubberband detects sudden position
-- jumps (>8 studs/frame) that indicate a server correction and undoes them.
-- ============================================
noclipLastCFrame = nil  -- anti-rubberband: tracks last known good position

-- [OPT] Frame skip counter untuk NoClip
local _noclipFrame = 0
noclipConn = RunService.Heartbeat:Connect(function()
    if not Toggles.NoClip or not Toggles.NoClip.Value then
        noclipLastCFrame = nil
        _noclipFrame = 0
        return
    end
    -- [OPT] Jalankan tiap 2 frame saja (30fps)  - Â cukup untuk NoClip
    _noclipFrame = _noclipFrame + 1
    if _noclipFrame % 2 ~= 0 then return end

    local char = LocalPlayer.Character
    if not char then noclipLastCFrame = nil return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then noclipLastCFrame = nil return end

    noclipLastCFrame = root.CFrame

    -- Disable collision on all body parts before physics resolves Solt frame
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)
table.insert(connections, noclipConn)

-- ============================================
-- FLY HACK
-- ============================================
startFly = function()
    stopFly()
    local char = LocalPlayer.Character
    if not char then return end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.PlatformStand = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = rootPart

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 9000
    flyBG.CFrame = Workspace.CurrentCamera.CFrame
    flyBG.Parent = rootPart

    flyActive = true
end

stopFly = function()
    flyActive = false
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end

    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

local flyMoveConn = RunService.RenderStepped:Connect(function()
    if not Toggles.Fly then return end
    if not Toggles.Fly.Value or not flyActive then return end

    local char = LocalPlayer.Character
    if not char or not char.Parent then
        stopFly()
        return
    end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local cam = Workspace.CurrentCamera
    local speed = Options.FlySpeed.Value
    local dir = Vector3.new(0, 0, 0)

    local moveVector = Vector3.new(0, 0, 0)
    pcall(function()
        local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule", 0.1))
        moveVector = PlayerModule:GetControls():GetMoveVector()
    end)

    if moveVector.Magnitude > 0 then
        dir = (cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)
    else
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

    if dir.Magnitude > 0 then dir = dir.Unit end

    if flyBV then flyBV.Velocity = dir * speed end
    if flyBG then flyBG.CFrame = cam.CFrame end
end)
table.insert(connections, flyMoveConn)

-- ============================================
-- INF JUMP (Holdable for PC & Mobile)
-- ============================================
local lastJump = 0
local function doInfJump()
    if not (Toggles.InfJump and Toggles.InfJump.Value) then return end
    local now = tick()
    if now - lastJump > 0.15 then
        lastJump = now
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

-- Fallback for immediate response when tapped/pressed initially
local infJumpReqConn = UserInputService.JumpRequest:Connect(doInfJump)
table.insert(connections, infJumpReqConn)

-- Heartbeat loop to detect holding Space (PC) or JumpButton (Mobile)
local infJumpHoldConn = RunService.Heartbeat:Connect(function()
    if not (Toggles.InfJump and Toggles.InfJump.Value) then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    local isHolding = false
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        isHolding = true
    elseif hum and hum.Jump then
        -- Native fallback: Roblox's ControlModule sets this to true continuously when jump is held.
        -- Unlike GuiObject.InputBegan, this naturally ignores camera swipes!
        isHolding = true
    end
    
    if isHolding then
        doInfJump()
    end
end)
table.insert(connections, infJumpHoldConn)

-- ============================================
-- FULLBRIGHT
-- ============================================
enableFullbright = function()
    if not originalLighting.stored then
        originalLighting.Brightness = Lighting.Brightness
        originalLighting.Ambient = Lighting.Ambient
        originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
        originalLighting.ClockTime = Lighting.ClockTime
        originalLighting.FogEnd = Lighting.FogEnd
        originalLighting.FogStart = Lighting.FogStart
        originalLighting.GlobalShadows = Lighting.GlobalShadows
        originalLighting.stored = true
    end

    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.GlobalShadows = false
end

disableFullbright = function()
    if originalLighting.stored then
        Lighting.Brightness = originalLighting.Brightness
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.FogStart = originalLighting.FogStart
        Lighting.GlobalShadows = originalLighting.GlobalShadows
    end
end

-- ============================================
-- AUTO SPRINT
-- [FIXED v7.3.1] Use correct SendKeyEvent signature with game object
-- ============================================
local autoSprintConn = nil
local lastSprintState = false

startAutoSprint = function()
    if autoSprintActive then return end
    autoSprintActive = true
    lastSprintState = false

    autoSprintConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        local isMoving = humanoid.MoveDirection.Magnitude > 0
        if isMoving ~= lastSprintState then
            lastSprintState = isMoving
            
            pcall(function()
                char:SetAttribute("SprintingClient", isMoving)
                local sprintEvent = char:FindFirstChild("WalkSpeedClient") and char.WalkSpeedClient:FindFirstChild("Sprint")
                if sprintEvent then
                    sprintEvent:FireServer(isMoving)
                else
                    game:GetService("VirtualInputManager"):SendKeyEvent(isMoving, Enum.KeyCode.LeftShift, false, game)
                end
            end)
        end
    end)
    table.insert(connections, autoSprintConn)
end

stopAutoSprint = function()
    if not autoSprintActive then return end
    autoSprintActive = false
    
    if autoSprintConn then
        autoSprintConn:Disconnect()
        autoSprintConn = nil
    end
    
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            char:SetAttribute("SprintingClient", false)
            local sprintEvent = char:FindFirstChild("WalkSpeedClient") and char.WalkSpeedClient:FindFirstChild("Sprint")
            if sprintEvent then
                sprintEvent:FireServer(false)
            else
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
            end
        end
    end)
end

-- ============================================
-- ANTI-AFK
-- ============================================
startAntiAFK = function()
    stopAntiAFK()
    antiAFKConn = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    table.insert(connections, antiAFKConn)
end

stopAntiAFK = function()
    if antiAFKConn then
        antiAFKConn:Disconnect()
        antiAFKConn = nil
    end
end

end
_initMovement()

local function _initKillAura()

-- ============================================
-- KILL AURA (FE Bypass - Swing/HitTargets)
-- [IMPROVED v7.3.3] Major improvements:
--                  - Target nearest monster first
--                  - Faster target updates (RenderStepped)
--                  - Auto-detect weapon swing speed
--                  - Extended range option (server-side trick)
--                  - More robust and stable with pcall wrappers
-- ============================================
killAuraLastSwing = 0
killAuraCurrentTarget = nil
killAuraTargetDistance = nil

-- Weapon swing speeds (seconds between attacks)
local weaponSwingSpeeds = {
    -- Fast weapons (0.2-0.3s)
    ["Knife"] = 0.25,
    ["Katana"] = 0.3,
    ["Crowbar"] = 0.35,
    -- Medium weapons (0.4-0.5s)
    ["Bat"] = 0.45,
    ["Spiked Bat"] = 0.45,
    ["Hatchet"] = 0.4,
    ["Scythe"] = 0.4,
    ["Spear"] = 0.4,
    -- Slow weapons (0.5-0.7s)
    ["Fire Axe"] = 0.55,
    ["Sledgehammer"] = 0.6,
    ["Chainsaw"] = 0.35,  -- Chainsaw is fast once running
    ["Riot Shield"] = 0.5,
}

-- Get weapon swing speed based on equipped tool
local function getWeaponSwingSpeed()
    local char = LocalPlayer.Character
    if not char then return 0.5 end
    
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return 0.5 end
    
    local toolName = tool.Name
    
    -- Check exact match first
    if weaponSwingSpeeds[toolName] then
        return weaponSwingSpeeds[toolName]
    end
    
    -- Partial match for variants (e.g., "Golden Knife", "Rusty Knife")
    for weaponName, speed in pairs(weaponSwingSpeeds) do
        if string.find(toolName:lower(), weaponName:lower()) then
            return speed
        end
    end
    
    -- Default speed for unknown weapons
    return 0.5
end

-- Collect all valid kill aura targets within range, sorted by chosen priority.
-- Returns an array of { mob, dist, health, maxHealth } tables.
-- [FIX] Only targets known mob types (mobNames whitelist).
--       Explicitly excludes ALL player characters so friendly-fire is impossible.
local function findTargetsInRange(range)
    local char = LocalPlayer.Character
    if not char then return {} end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end

    -- Build a fast lookup set of every player's current character
    local playerCharSet = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            playerCharSet[p.Character] = true
        end
    end

    local targets = {}
    local myPos   = hrp.Position

    -- Prioritas: scan charactersFolder dulu kalau ada (sangat cepat karena tanpa rekursi)
    if charactersFolder then
        for _, obj in ipairs(charactersFolder:GetChildren()) do
            if obj:IsA("Model") and obj ~= char and not playerCharSet[obj] then
                local mobHRP = obj:FindFirstChild("HumanoidRootPart")
                local mobHum = obj:FindFirstChildOfClass("Humanoid")
                if mobHRP and mobHum and mobHum.Health > 0 then
                    local dist = (mobHRP.Position - myPos).Magnitude
                    if dist <= range then
                        table.insert(targets, { mob = obj, dist = dist, health = mobHum.Health, maxHealth = mobHum.MaxHealth })
                    end
                end
            end
        end
    else
        -- Fallback: Scan rekursif seluruh Workspace jika folder karakter tidak ditemukan
        local function scanFolder(parent)
            for _, obj in ipairs(parent:GetChildren()) do
                if obj:IsA("Model") then
                    if obj ~= char and not playerCharSet[obj] then
                        local mobHRP = obj:FindFirstChild("HumanoidRootPart")
                        local mobHum = obj:FindFirstChildOfClass("Humanoid")
                        if mobHRP and mobHum and mobHum.Health > 0 then
                            local dist = (mobHRP.Position - myPos).Magnitude
                            if dist <= range then
                                table.insert(targets, { mob = obj, dist = dist, health = mobHum.Health, maxHealth = mobHum.MaxHealth })
                            end
                        else
                            -- Hanya telusuri model bersarang jika bukan model karakter
                            scanFolder(obj)
                        end
                    end
                elseif obj:IsA("Folder") then
                    scanFolder(obj)
                end
            end
        end
        scanFolder(Workspace)
    end

    local priority = Options.KillAuraPriority and Options.KillAuraPriority.Value or "Nearest"
    if priority == "Nearest" then
        table.sort(targets, function(a, b) return a.dist < b.dist end)
    elseif priority == "Lowest HP" then
        table.sort(targets, function(a, b) return a.health < b.health end)
    elseif priority == "Highest HP" then
        table.sort(targets, function(a, b) return a.health > b.health end)
    end

    return targets
end


stopKillAura = function()
    if killAuraConn then
        killAuraConn:Disconnect()
        killAuraConn = nil
    end
    killAuraLastSwing = 0
    killAuraCurrentTarget = nil
    killAuraTargetDistance = nil
    -- Hide visual indicator drawings
    if killAuraIndicatorLine   then killAuraIndicatorLine.Visible   = false end
    if killAuraIndicatorCircle then killAuraIndicatorCircle.Visible = false end
    -- [Potassium] Restore default simulation radius when kill aura stops
    pcall(function()
        if setsimulationradius then setsimulationradius(50, 300) end
    end)
end

startKillAura = function()
    stopKillAura()

    -- Create indicator Drawing objects once; reused every frame
    if not killAuraIndicatorLine then
        killAuraIndicatorLine             = Drawing.new("Line")
        killAuraIndicatorLine.Thickness   = 1.5
        killAuraIndicatorLine.Color       = Color3.fromRGB(255, 55, 55)
        killAuraIndicatorLine.Transparency = 0.65
        killAuraIndicatorLine.Visible     = false
    end
    if not killAuraIndicatorCircle then
        killAuraIndicatorCircle             = Drawing.new("Circle")
        killAuraIndicatorCircle.Thickness   = 1.5
        killAuraIndicatorCircle.Color       = Color3.fromRGB(255, 55, 55)
        killAuraIndicatorCircle.Transparency = 0.55
        killAuraIndicatorCircle.Filled      = false
        killAuraIndicatorCircle.Visible     = false
    end

    -- [Potassium] Raise simulation radius so the server accepts hits at extended range
    pcall(function()
        if setsimulationradius then setsimulationradius(1000, 1000) end
    end)

-- [OPT] Cache target scan: scan tiap 0.05s (20fps) bukan 60fps
local _kaScanTimer    = 0
local _kaCachedTargets = {}
local _kaCachedRange   = 0

    killAuraConn = RunService.Heartbeat:Connect(function()
        if not Toggles.KillAura or not Toggles.KillAura.Value then
            killAuraCurrentTarget = nil
            if killAuraIndicatorLine   then killAuraIndicatorLine.Visible   = false end
            if killAuraIndicatorCircle then killAuraIndicatorCircle.Visible = false end
            return
        end

        local success, err = pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local tool = char:FindFirstChildOfClass("Tool")

            if not tool then
                killAuraCurrentTarget = nil
                if killAuraIndicatorLine   then killAuraIndicatorLine.Visible   = false end
                if killAuraIndicatorCircle then killAuraIndicatorCircle.Visible = false end
                return
            end

            local swing       = tool:FindFirstChild("Swing")
            local hitTargets  = tool:FindFirstChild("HitTargets")
            local remoteClick = tool:FindFirstChild("RemoteClick")

            local baseRange        = Options.KillAuraRange and Options.KillAuraRange.Value or 6
            local useExtendedRange = Toggles.KillAuraExtendedRange and Toggles.KillAuraExtendedRange.Value
            local attackRange      = useExtendedRange and (baseRange + 2) or baseRange
            local now = tick()

            -- [OPT] Scan target hanya 20fps, bukan 60fps (hemat CPU signifikan)
            if now - _kaScanTimer >= 0.05 or _kaCachedRange ~= attackRange then
                _kaScanTimer    = now
                _kaCachedRange  = attackRange
                _kaCachedTargets = findTargetsInRange(attackRange)
            end
            local targets = _kaCachedTargets
            killAuraCurrentTarget  = targets[1] and targets[1].mob  or nil
            killAuraTargetDistance = targets[1] and targets[1].dist or nil

            -- Visual indicator
            local showIndicator = Toggles.KillAuraShowIndicator and Toggles.KillAuraShowIndicator.Value
            if showIndicator and killAuraCurrentTarget then
                local camera = Workspace.CurrentCamera
                if camera then
                    local tHRP = killAuraCurrentTarget:FindFirstChild("HumanoidRootPart")
                    if tHRP then
                        local sp, onScreen = camera:WorldToViewportPoint(tHRP.Position)
                        if onScreen and sp.Z > 0 then
                            local vp     = camera.ViewportSize
                            local center = Vector2.new(vp.X / 2, vp.Y)  -- bottom-center
                            local tgt    = Vector2.new(sp.X, sp.Y)
                            killAuraIndicatorLine.From    = center
                            killAuraIndicatorLine.To      = tgt
                            killAuraIndicatorLine.Visible = true
                            -- Circle radius scales inversely with distance (8â€“40 px)
                            local radius = math.clamp(1200 / math.max(killAuraTargetDistance, 1), 8, 40)
                            killAuraIndicatorCircle.Position = tgt
                            killAuraIndicatorCircle.Radius   = radius
                            killAuraIndicatorCircle.Visible  = true
                        else
                            killAuraIndicatorLine.Visible   = false
                            killAuraIndicatorCircle.Visible = false
                        end
                    end
                end
            else
                if killAuraIndicatorLine   then killAuraIndicatorLine.Visible   = false end
                if killAuraIndicatorCircle then killAuraIndicatorCircle.Visible = false end
            end

            if #targets == 0 then return end

            -- effectiveSwingRate = max(weaponSpeed, userSetting)
            -- We NEVER swing faster than the weapon physically allows.
            -- This prevents the server from rejecting rapid-fire hits.
            local weaponSpeed        = getWeaponSwingSpeed()
            local userSwingRate      = (Options.KillAuraSwingRate and tonumber(Options.KillAuraSwingRate.Value)) or weaponSpeed
            local effectiveSwingRate = math.max(weaponSpeed, userSwingRate)
            if now - killAuraLastSwing < effectiveSwingRate then return end

            -- == AoE attack ==
            -- Pass ALL mobs in range to HitTargets in a single FireServer call.
            -- The server validates each entry; only reachable mobs take damage.
            local mobModels = {}
            for _, t in ipairs(targets) do
                table.insert(mobModels, t.mob)
            end

            local attackSuccess = false

            if swing and hitTargets then
                local s1, e1 = pcall(function() swing:FireServer() end)
                if s1 then
                    -- [FIX] Record swing time immediately after Swing fires.
                    -- If HitTargets errors the cooldown is still respected,
                    -- preventing rapid-fire Swing spam that the server will reject.
                    killAuraLastSwing = now
                    attackSuccess = true
                    local s2, e2 = pcall(function() hitTargets:FireServer(mobModels) end)
                    if not s2 then warn("[KillAura] HitTargets error: " .. tostring(e2)) end
                else
                    warn("[KillAura] Swing error: " .. tostring(e1))
                end
            elseif remoteClick then
                -- RemoteClick accepts one target  - Â use the highest-priority mob
                local s, e = pcall(function() remoteClick:FireServer(targets[1].mob) end)
                attackSuccess = s
                if not s then warn("[KillAura] RemoteClick error: " .. tostring(e)) end
            end

            if attackSuccess and killAuraLastSwing ~= now then
                killAuraLastSwing = now
            end
        end)

        if not success then
                            warn("[KillAura] Error: " .. tostring(err))
        end
    end)
end

end
_initKillAura()

local _mobileAimBtnGui = nil
local updateAimLockMobileLockState = function(_) end
local updateAimLockMobileButton = function(_) end
local createAimLockMobileButton = function() end

local function _initAimbot()

-- ============================================
-- SILENT AIM (360 Degree) & AUTO COMBAT
-- [REWRITE v7.4] Replaced camera aimbot with pure distance-based Silent Aim and independent loops
-- ============================================

local originalGetTargetPos = _G.getCurrentAutoTargetPosition
local silentAimHooked = false

local _STA_MOB_NAMES = {
    Zombie = true, Runner = true, Crawler = true,
    Brute = true, Spitter = true, Riot = true, Boss = true,
}

local function _isMatchingFaction(mob, targetMode)
    if not mob then return false end
    
    local name = mob.Name
    local isZombie = mob:GetAttribute("Zombie") == true or _STA_MOB_NAMES[name] == true or name:lower():match("zombie") or name:lower():match("brute")
    local isBandit = mob:GetAttribute("Bandit") == true or name:lower():match("bandit") or name:lower():match("raider")
    
    local modeStr = tostring(targetMode or "Zombies")
    
    if modeStr == "Bandits" or modeStr == "2" or targetMode == 2 then
        return isBandit
    elseif modeStr == "Both" or modeStr == "3" or targetMode == 3 then
        return isZombie or isBandit
    else -- "Zombies" or 1 or default
        return isZombie
    end
end

local function _resolveAimPartName(aimPart)
    local pStr = tostring(aimPart or "Head")
    if pStr == "Torso" or pStr == "2" or aimPart == 2 then
        return "Torso"
    elseif pStr == "HumanoidRootPart" or pStr == "3" or aimPart == 3 then
        return "HumanoidRootPart"
    else
        return "Head"
    end
end

local function _getAllValidMobs()
    local char = LocalPlayer.Character
    if not char then return {} end
    local playerCharSet = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then playerCharSet[p.Character] = true end
    end

    local validMobs = {}
    local function _checkObj(obj)
        if obj and obj:IsA("Model") and obj ~= char and not playerCharSet[obj] then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hp = humanoid and humanoid.Health or (obj:FindFirstChild("MockHumanoid") and obj.MockHumanoid:GetAttribute("Health") or 0)
            if (humanoid and hp > 0) or hp > 0 then
                if not obj:GetAttribute("Dead") and not obj:GetAttribute("Untouchable") then
                    table.insert(validMobs, obj)
                end
            end
        end
    end

    if charactersFolder then
        for _, obj in ipairs(charactersFolder:GetChildren()) do _checkObj(obj) end
    elseif Workspace:FindFirstChild("Characters") then
        for _, obj in ipairs(Workspace.Characters:GetChildren()) do _checkObj(obj) end
    else
        for _, obj in ipairs(Workspace:GetChildren()) do _checkObj(obj) end
    end

    return validMobs
end

-- Get the closest valid target based purely on distance (360 degrees)
local function getSilentTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local maxRange = Options.SilentAimRange and Options.SilentAimRange.Value or 200
    local targetMode = Options.SilentAimTarget and Options.SilentAimTarget.Value or "Zombies"
    local aimPart = _resolveAimPartName(Options.SilentAimPart and Options.SilentAimPart.Value)
    local checkWall = Toggles.SilentAimWallCheck and Toggles.SilentAimWallCheck.Value

    local bestTarget = nil
    local bestScore = maxRange

    local mobs = _getAllValidMobs()
    for _, mob in ipairs(mobs) do
        if _isMatchingFaction(mob, targetMode) then
            local mobRoot = mob:FindFirstChild(aimPart) or mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
            if mobRoot then
                local dist = (mobRoot.Position - myRoot.Position).Magnitude
                if dist <= bestScore then
                    local canSee = true
                    if checkWall then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {char, mob}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        rayParams.IgnoreWater = true
                        local hit = workspace:Raycast(myRoot.Position + Vector3.new(0, 1.5, 0), mobRoot.Position - (myRoot.Position + Vector3.new(0, 1.5, 0)), rayParams)
                        if hit and hit.Instance and hit.Instance.CanCollide then
                            canSee = false
                        end
                    end
                    
                    if canSee then
                        bestScore = dist
                        bestTarget = { character = mob, rootPart = mobRoot }
                    end
                end
            end
        end
    end

    return bestTarget
end

-- ============================================
-- AIM LOCK (CAMERA LOCK) ENGINE
-- ============================================
local _lockedAimTarget = nil

local function getAimLockTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local maxDist = Options.AimLockRange and Options.AimLockRange.Value or 200
    local targetMode = Options.AimLockTarget and Options.AimLockTarget.Value or "Zombies"
    local aimPartName = _resolveAimPartName(Options.AimLockPart and Options.AimLockPart.Value)
    local checkWall = Toggles.AimLockWallCheck and Toggles.AimLockWallCheck.Value
    
    local bestTarget = nil
    local bestDist = maxDist

    local mobs = _getAllValidMobs()
    for _, mob in ipairs(mobs) do
        if _isMatchingFaction(mob, targetMode) then
            local targetPart = mob:FindFirstChild(aimPartName) or mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
            if targetPart then
                local worldDist = (targetPart.Position - myRoot.Position).Magnitude
                if worldDist <= bestDist then
                    local canSee = true
                    if checkWall then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {char, mob}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        rayParams.IgnoreWater = true
                        local hit = workspace:Raycast(myRoot.Position + Vector3.new(0, 1.5, 0), targetPart.Position - (myRoot.Position + Vector3.new(0, 1.5, 0)), rayParams)
                        if hit and hit.Instance and hit.Instance.CanCollide then
                            canSee = false
                        end
                    end
                    
                    if canSee then
                        bestDist = worldDist
                        bestTarget = { character = mob, targetPart = targetPart }
                    end
                end
            end
        end
    end

    return bestTarget
end

pcall(function()
    RunService:UnbindFromRenderStep("SolanaHubAimLock")
end)

RunService:BindToRenderStep("SolanaHubAimLock", Enum.RenderPriority.Camera.Value + 1, function()
    local camera = workspace.CurrentCamera
    if not camera then return end

    -- Aim Lock Camera tracking
    if Toggles.AimLock and Toggles.AimLock.Value then
        local char = LocalPlayer.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if char and myRoot then
            local aimPartName = _resolveAimPartName(Options.AimLockPart and Options.AimLockPart.Value)
            local maxLockDist = Options.AimLockRange and Options.AimLockRange.Value or 200
            local targetPart = nil
            
            -- Verify current locked target is still alive & in range
            if _lockedAimTarget and _lockedAimTarget.character and _lockedAimTarget.character.Parent then
                local mob = _lockedAimTarget.character
                local humanoid = mob:FindFirstChildOfClass("Humanoid")
                local hp = humanoid and humanoid.Health or (mob:FindFirstChild("MockHumanoid") and mob.MockHumanoid:GetAttribute("Health") or 0)
                if hp > 0 and not mob:GetAttribute("Dead") then
                    targetPart = mob:FindFirstChild(aimPartName) or mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
                    local dist = targetPart and (targetPart.Position - myRoot.Position).Magnitude or 999
                    if dist > maxLockDist then targetPart = nil end
                end
            end
            
            -- If no current target or dead, find new one
            if not targetPart then
                _lockedAimTarget = getAimLockTarget()
                if _lockedAimTarget then
                    targetPart = _lockedAimTarget.targetPart
                end
            end
            
            if targetPart then
                local targetPos = targetPart.Position
                local currentCamPos = camera.CFrame.Position
                local targetLook = CFrame.lookAt(currentCamPos, targetPos)
                
                local smooth = Options.AimLockSmoothness and Options.AimLockSmoothness.Value or 0
                if smooth <= 0.05 then
                    camera.CFrame = targetLook
                else
                    local alpha = math.clamp(1 / (smooth * 2.5), 0.05, 0.95)
                    camera.CFrame = camera.CFrame:Lerp(targetLook, alpha)
                end

                -- Auto Align Character Body (Built-in ShiftLock / Combat Stance)
                if myRoot then
                    local flatTarget = Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z)
                    local bodyLook = CFrame.lookAt(myRoot.Position, flatTarget)
                    if smooth <= 0.05 then
                        myRoot.CFrame = bodyLook
                    else
                        myRoot.CFrame = myRoot.CFrame:Lerp(bodyLook, 0.35)
                    end
                end
            end
        end
    else
        _lockedAimTarget = nil
    end
end)

-- ============================================
-- AIM LOCK MOBILE QUICK BUTTON (FLOATING GUI)
-- ============================================
local _mobileAimBtn = nil
local _mobileAimLabel = nil
local _mobileAimSubLabel = nil
local _mobileAimStroke = nil
local _mobileAimLockBadge = nil
local _mobileAimLockBadgeStroke = nil

updateAimLockMobileLockState = function(isLocked)
    if not _mobileAimLockBadge or not _mobileAimLockBadgeStroke then return end
    if isLocked then
        _mobileAimLockBadge.Text = "LOCK"
        _mobileAimLockBadge.TextColor3 = Color3.fromRGB(255, 130, 130)
        _mobileAimLockBadge.BackgroundColor3 = Color3.fromRGB(65, 20, 20)
        _mobileAimLockBadgeStroke.Color = Color3.fromRGB(240, 70, 70)
    else
        _mobileAimLockBadge.Text = "PIN"
        _mobileAimLockBadge.TextColor3 = Color3.fromRGB(130, 245, 170)
        _mobileAimLockBadge.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
        _mobileAimLockBadgeStroke.Color = Color3.fromRGB(60, 200, 110)
    end
end

updateAimLockMobileButton = function(state)
    if not _mobileAimBtn or not _mobileAimStroke or not _mobileAimLabel or not _mobileAimSubLabel then return end
    if state then
        _mobileAimBtn.BackgroundColor3 = Color3.fromRGB(18, 52, 38)
        _mobileAimStroke.Color = Color3.fromRGB(0, 230, 140)
        _mobileAimLabel.TextColor3 = Color3.fromRGB(0, 255, 160)
        _mobileAimSubLabel.Text = "LOCKED"
        _mobileAimSubLabel.TextColor3 = Color3.fromRGB(0, 255, 160)
    else
        _mobileAimBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
        _mobileAimStroke.Color = Color3.fromRGB(70, 70, 95)
        _mobileAimLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
        _mobileAimSubLabel.Text = "OFF"
        _mobileAimSubLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    end
end

createAimLockMobileButton = function()
    if not UserInputService.TouchEnabled then return end
    if _mobileAimBtnGui then
        pcall(function() _mobileAimBtnGui:Destroy() end)
        _mobileAimBtnGui = nil
    end

    local parent = nil
    pcall(function() parent = gethui and gethui() end)
    if not parent then
        pcall(function() parent = game:GetService("CoreGui") end)
    end
    if not parent then
        parent = LocalPlayer:FindFirstChild("PlayerGui")
    end
    if not parent then return end

    _mobileAimBtnGui = Instance.new("ScreenGui")
    _mobileAimBtnGui.Name = "SolanaHubMobileAimLock"
    _mobileAimBtnGui.ResetOnSpawn = false
    _mobileAimBtnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _mobileAimBtnGui.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Name = "AimButton"
    btn.Size = UDim2.new(0, 56, 0, 56)
    btn.Position = UDim2.new(1, -72, 0.45, 0)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    btn.BackgroundTransparency = 0.15
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Parent = _mobileAimBtnGui
    _mobileAimBtn = btn

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(70, 70, 95)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn
    _mobileAimStroke = stroke

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(1, 0, 0.55, 0)
    iconLabel.Position = UDim2.new(0, 0, 0.08, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Text = "AIM"
    iconLabel.TextSize = 13
    iconLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
    iconLabel.Parent = btn
    _mobileAimLabel = iconLabel

    local subLabel = Instance.new("TextLabel")
    subLabel.Name = "State"
    subLabel.Size = UDim2.new(1, 0, 0.35, 0)
    subLabel.Position = UDim2.new(0, 0, 0.58, 0)
    subLabel.BackgroundTransparency = 1
    subLabel.Font = Enum.Font.GothamBold
    subLabel.Text = "OFF"
    subLabel.TextSize = 10
    subLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    subLabel.Parent = btn
    _mobileAimSubLabel = subLabel

    -- Lock Position Pin / Badge (Draggable Toggle)
    local lockBadge = Instance.new("TextButton")
    lockBadge.Name = "LockPin"
    lockBadge.Size = UDim2.new(0, 26, 0, 14)
    lockBadge.Position = UDim2.new(1, -16, 0, -4)
    lockBadge.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
    lockBadge.Font = Enum.Font.GothamBold
    lockBadge.Text = "PIN"
    lockBadge.TextSize = 8
    lockBadge.TextColor3 = Color3.fromRGB(130, 245, 170)
    lockBadge.ZIndex = 10
    lockBadge.AutoButtonColor = false
    lockBadge.Parent = btn
    _mobileAimLockBadge = lockBadge

    local badgeCorner = Instance.new("UICorner")
    badgeCorner.CornerRadius = UDim.new(0, 4)
    badgeCorner.Parent = lockBadge

    local badgeStroke = Instance.new("UIStroke")
    badgeStroke.Thickness = 1
    badgeStroke.Color = Color3.fromRGB(60, 200, 110)
    badgeStroke.Parent = lockBadge
    _mobileAimLockBadgeStroke = badgeStroke

    lockBadge.MouseButton1Click:Connect(function()
        if Toggles.AimLockLockButtonPos then
            Toggles.AimLockLockButtonPos:SetValue(not Toggles.AimLockLockButtonPos.Value)
        end
    end)

    -- Mobile Dragging and Tap Logic
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local totalMovement = 0

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local isLocked = Toggles.AimLockLockButtonPos and Toggles.AimLockLockButtonPos.Value
            if not isLocked then
                dragging = true
                dragStart = input.Position
                startPos = btn.Position
                totalMovement = 0
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            else
                dragging = false
                totalMovement = 0
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local isLocked = Toggles.AimLockLockButtonPos and Toggles.AimLockLockButtonPos.Value
            if not isLocked then
                local delta = input.Position - dragStart
                totalMovement = totalMovement + math.abs(delta.X) + math.abs(delta.Y)
                btn.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local isLocked = Toggles.AimLockLockButtonPos and Toggles.AimLockLockButtonPos.Value
            dragging = false
            -- If locked or movement was small tap, toggle Aim Lock
            if isLocked or totalMovement < 15 then
                if Toggles.AimLock then
                    Toggles.AimLock:SetValue(not Toggles.AimLock.Value)
                end
            end
        end
    end)

    updateAimLockMobileButton(Toggles.AimLock and Toggles.AimLock.Value or false)
    updateAimLockMobileLockState(Toggles.AimLockLockButtonPos and Toggles.AimLockLockButtonPos.Value or false)
end

if UserInputService.TouchEnabled then
    pcall(createAimLockMobileButton)
end

-- ============================================================
-- SILENT AIM (AUTO SHOOT) & AUTO RELOAD ENGINE
-- ============================================================
local lastShoot = 0
local lastReload = 0
local _lastAutoReloadTool = nil

getgenv()._NX_AutoCombatConn = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local tool = char:FindFirstChildWhichIsA("Tool")
    if not tool then _lastAutoReloadTool = nil; return end
    local now = os.clock()

    -- Reset reload timer when tool changes (unequip → re-equip)
    if tool ~= _lastAutoReloadTool then
        _lastAutoReloadTool = tool
        lastReload = 0
    end

    -- Auto Shoot
    if Toggles.AutoShoot and Toggles.AutoShoot.Value then
        if now - lastShoot >= 0.15 then
            local target = getSilentTarget()
            if target and target.character then
                local aimPartName = _resolveAimPartName(Options.SilentAimPart and Options.SilentAimPart.Value)
                local targetPart = target.character:FindFirstChild(aimPartName) or target.rootPart
                if targetPart then
                    local aimPos = targetPart.Position
                    lastShoot = now
                    
                    -- 1. Activate tool
                    pcall(function() tool:Activate() end)
                
                    -- 2. Direct Hit Replication across all gun remotes
                    for _, child in ipairs(tool:GetDescendants()) do
                        if child:IsA("RemoteEvent") and (child.Name == "Shoot" or child.Name == "Fire" or child.Name == "Attack" or child.Name == "HitTargets") then
                            pcall(function()
                                local headPos = char:FindFirstChild("Head") and char.Head.Position or myRoot.Position
                                child:FireServer(
                                    headPos,
                                    {
                                        {
                                            Target = aimPos,
                                            HitData = {
                                                {
                                                    HitChar = target.character,
                                                    HitPos = aimPos,
                                                    HitPart = targetPart
                                                }
                                            }
                                        }
                                    },
                                    0, -- ChargeAmount
                                    1  -- ShotID
                                )
                            end)
                            pcall(function() child:FireServer(aimPos, target.character) end)
                            pcall(function() child:FireServer(target.character, aimPos) end)
                        end
                    end
                end
            end
        end
    end

    -- Auto Reload
    if Toggles.AutoReload and Toggles.AutoReload.Value then
        if now - lastReload >= 1.25 then
            lastReload = now
            task.spawn(function()
                -- 1) Try direct child "Reload" RemoteFunction
                local reloadObj = tool:FindFirstChild("Reload")
                if reloadObj and reloadObj:IsA("RemoteFunction") then
                    local syncAmmo = tool:FindFirstChild("SyncAmmo")
                    if syncAmmo and syncAmmo:IsA("RemoteEvent") then
                        pcall(function() syncAmmo:FireServer() end)
                    end
                    pcall(function() reloadObj:InvokeServer() end)
                    task.wait(0.2)
                    pcall(function() reloadObj:InvokeServer(false) end)
                    return
                end

                -- 2) Try direct child "Reload" RemoteEvent
                if reloadObj and reloadObj:IsA("RemoteEvent") then
                    pcall(function() reloadObj:FireServer() end)
                    return
                end

                -- 3) Search recursively for Reload remote inside tool
                local reloadRemote = tool:FindFirstChild("Reload", true)
                if reloadRemote then
                    if reloadRemote:IsA("RemoteFunction") then
                        local syncAmmo = tool:FindFirstChild("SyncAmmo", true)
                        if syncAmmo and syncAmmo:IsA("RemoteEvent") then
                            pcall(function() syncAmmo:FireServer() end)
                        end
                        pcall(function() reloadRemote:InvokeServer() end)
                        return
                    elseif reloadRemote:IsA("RemoteEvent") then
                        pcall(function() reloadRemote:FireServer() end)
                        return
                    end
                end

                -- 4) Fallback: fire Reload through mobile touch button or VIM (PC only)
                pcall(function()
                    -- Try mobile touch button first (safe, no input mode switch)
                    local touchButtons = LocalPlayer.PlayerGui:FindFirstChild("DeviceSupportUI")
                    local reloadBtn = touchButtons and touchButtons:FindFirstChild("TouchButtons") and touchButtons.TouchButtons:FindFirstChild("Reload")
                    if reloadBtn then
                        -- Fire the mobile reload button
                        pcall(function()
                            for _, conn in ipairs(getconnections(reloadBtn.MouseButton1Down)) do
                                conn:Fire()
                            end
                        end)
                        return
                    end

                    -- PC only: simulate R key press (will change input mode on mobile!)
                    if UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled then
                        local Vim = game:GetService("VirtualInputManager")
                        Vim:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        task.wait()
                        Vim:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                    end
                end)
            end)
        end
    end
end)

end
_initAimbot()

local function _initCombatUtils()

-- ============================================
-- REMOVE FOG
-- [IMPROVED v7.3.3] Now handles Workspace.Fog folder
--                  - Makes all fog objects client-side invisible
--                  - Properly restores visibility on disable
-- ============================================
local fogOriginalStates = {}  -- Store original visibility states
local fogObjects = {}  -- Reference to fog objects
local fogFEConns  = {}  -- [FE Bypass] Connections that prevent server from restoring fog

local function makeFogObjectInvisible(obj)
    local success, err = pcall(function()
        -- Store original state before modifying
        local originalState = {}
        
        if obj:IsA("BasePart") then
            -- Parts, MeshParts, Unions, TrussParts, etc.
            originalState.Transparency = obj.Transparency
            originalState.Material = obj.Material
            obj.Transparency = 1
            obj.Material = Enum.Material.Air
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("ParticleEmitter") then
            originalState.Enabled = obj.Enabled
            obj.Enabled = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Beam") then
            originalState.Enabled = obj.Enabled
            obj.Enabled = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Trail") then
            originalState.Enabled = obj.Enabled
            obj.Enabled = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Smoke") then
            originalState.Enabled = obj.Enabled
            obj.Enabled = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Fire") then
            originalState.Enabled = obj.Enabled
            obj.Enabled = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Sparkles") then
            originalState.Enabled = obj.Enabled
            obj.Enabled = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Explosion") then
            originalState.Visible = obj.Visible
            obj.Visible = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            originalState.Transparency = obj.Transparency
            obj.Transparency = 1
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Light") then
            -- PointLight, SpotLight, SurfaceLight
            originalState.Enabled = obj.Enabled
            obj.Enabled = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Highlight") then
            originalState.Enabled = obj.Enabled
            obj.Enabled = false
            fogOriginalStates[obj] = originalState
        elseif obj:IsA("Folder") or obj:IsA("Model") then
            -- Recursively handle containers
            for _, child in ipairs(obj:GetDescendants()) do
                makeFogObjectInvisible(child)
            end
        end
    end)
    if not success then
        warn("[RemoveFog] Failed to process object: " .. tostring(err))
    end
end

local function restoreFogObjectVisibility(obj)
    if fogOriginalStates[obj] then
        pcall(function()
            local state = fogOriginalStates[obj]
            if obj:IsA("BasePart") then
                obj.Transparency = state.Transparency
                obj.Material = state.Material
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") 
                or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") 
                or obj:IsA("Light") or obj:IsA("Highlight") then
                obj.Enabled = state.Enabled
            elseif obj:IsA("Explosion") then
                obj.Visible = state.Visible
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = state.Transparency
            end
        end)
    end
end

enableRemoveFog = function()
    -- Store Lighting fog settings (only once, so disable can restore originals)
    if not originalFog.stored then
        originalFog.FogEnd   = Lighting.FogEnd
        originalFog.FogStart = Lighting.FogStart
        originalFog.stored   = true
    end
    Lighting.FogEnd   = 100000
    Lighting.FogStart = 0

    -- Handle Atmosphere (visual density/haze separate from FogEnd)
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm then
        if originalFog.AtmDensity == nil then  -- store only once
            originalFog.AtmDensity = atm.Density
            originalFog.AtmHaze    = atm.Haze
            originalFog.AtmGlare   = atm.Glare
        end
        atm.Density = 0
        atm.Haze    = 0
        atm.Glare   = 0
    end

    -- [FE Bypass] Disconnect any previous server-override listeners and re-create them
    for _, conn in ipairs(fogFEConns) do pcall(function() conn:Disconnect() end) end
    fogFEConns = {}

    -- Lighting.Changed: immediately reapply FogEnd/FogStart if server changes them
    table.insert(fogFEConns, Lighting.Changed:Connect(function(prop)
        if not (Toggles.RemoveFog and Toggles.RemoveFog.Value) then return end
        if prop == "FogEnd"   then Lighting.FogEnd   = 100000 end
        if prop == "FogStart" then Lighting.FogStart = 0      end
    end))

    -- Atmosphere.Changed: keep density/haze/glare at zero
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere then
        table.insert(fogFEConns, atmosphere.Changed:Connect(function(prop)
            if not (Toggles.RemoveFog and Toggles.RemoveFog.Value) then return end
            if prop == "Density" then atmosphere.Density = 0 end
            if prop == "Haze"    then atmosphere.Haze    = 0 end
            if prop == "Glare"   then atmosphere.Glare   = 0 end
        end))
    end

    -- Handle Workspace.Fog folder
    local fogFolder = Workspace:FindFirstChild("Fog")
    if fogFolder then
        fogOriginalStates = {}
        fogObjects = {}

        for _, child in ipairs(fogFolder:GetChildren()) do
            table.insert(fogObjects, child)
            makeFogObjectInvisible(child)
        end
        for _, descendant in ipairs(fogFolder:GetDescendants()) do
            if not fogOriginalStates[descendant] then
                makeFogObjectInvisible(descendant)
            end
        end

        -- [FE Bypass] Hide any new fog objects the server adds dynamically
        table.insert(fogFEConns, fogFolder.ChildAdded:Connect(function(child)
            if not (Toggles.RemoveFog and Toggles.RemoveFog.Value) then return end
            makeFogObjectInvisible(child)
            for _, desc in ipairs(child:GetDescendants()) do
                makeFogObjectInvisible(desc)
            end
        end))

        Library:Notify({ Title = "Remove Fog", Description = "Enabled  -  " .. #fogObjects .. " fog objects hidden", Time = 2 })
    else
        Library:Notify({ Title = "Remove Fog", Description = "Enabled  -  Lighting fog cleared (no Fog folder found)", Time = 2 })
    end
end

disableRemoveFog = function()
    -- [FE Bypass] Disconnect all server-override listeners first
    for _, conn in ipairs(fogFEConns) do pcall(function() conn:Disconnect() end) end
    fogFEConns = {}

    -- Restore Lighting fog settings
    if originalFog.stored then
        Lighting.FogEnd   = originalFog.FogEnd
        Lighting.FogStart = originalFog.FogStart
    end

    -- Restore Atmosphere
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm and originalFog.AtmDensity ~= nil then
        atm.Density = originalFog.AtmDensity
        atm.Haze    = originalFog.AtmHaze
        atm.Glare   = originalFog.AtmGlare
        originalFog.AtmDensity = nil
        originalFog.AtmHaze    = nil
        originalFog.AtmGlare   = nil
    end

    -- Restore visibility of all fog objects
    for obj, _ in pairs(fogOriginalStates) do
        restoreFogObjectVisibility(obj)
    end

    fogOriginalStates = {}
    fogObjects = {}

    Library:Notify({ Title = "Remove Fog", Description = "Disabled  -  fog restored", Time = 2 })
end

-- ============================================
-- BUNNY HOP (Auto-jump while moving)
-- [ADDED v7.3] Automatic jumping for speed/momentum
-- ============================================
stopBhop = function()
    if bhopConn then
        bhopConn:Disconnect()
        bhopConn = nil
    end
    bhopActive = false
end

startBhop = function()
    stopBhop()
    bhopActive = true
    
    bhopConn = RunService.RenderStepped:Connect(function()
        if not Toggles.BunnyHop or not Toggles.BunnyHop.Value then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not root then return end
        
        -- Only jump if moving and on ground
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0.1 then
            local state = humanoid:GetState()
            if state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- ============================================
-- FUNNY DANCE FE
-- [ADDED] Plays a looping dance animation visible to all players on the server.
-- FE compatible: local character animations are replicated to server automatically.
-- Action4 priority overrides idle/walk so the dance plays continuously.
-- ============================================
local funnyDanceTrack = nil
local funnyDanceConn  = nil

-- Roblox built-in emote animation IDs (free, work on any avatar)
local DANCE_ANIM_IDS = {
    507770723,  -- Dance 1 (Shuffle)
    507772104,  -- Dance 2 (Twist)
    507771281,  -- Dance 3 (Robot)
}

stopFunnyDance = function()
    if funnyDanceConn then
        funnyDanceConn:Disconnect()
        funnyDanceConn = nil
    end
    if funnyDanceTrack then
        if funnyDanceTrack ~= "PHYS" then
            pcall(function() funnyDanceTrack:Stop(0.3) end)
        end
        funnyDanceTrack = nil
    end
end

startFunnyDance = function()
    stopFunnyDance()

    local selectedIdx = Options.DanceStyle and Options.DanceStyle.Value or 1
    local selectedId  = DANCE_ANIM_IDS[selectedIdx] or DANCE_ANIM_IDS[1]

    -- Physics-based dance state (fallback when the animation system is blocked)
    local physDanceConn = nil

    local function stopPhysDance()
        if physDanceConn then
            physDanceConn:Disconnect()
            physDanceConn = nil
        end
    end

    local function startPhysDance(char)
        stopPhysDance()
        local t = 0
        local spinDir = (selectedIdx % 2 == 0) and 1 or -1  -- alternate direction per style
        physDanceConn = RunService.Heartbeat:Connect(function(dt)
            if not Toggles.FunnyDance or not Toggles.FunnyDance.Value then
                stopPhysDance()
                return
            end
            local c = char or LocalPlayer.Character
            if not c then return end
            local root = c:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then return end
            t = t + dt
            -- Spin the character + slight vertical bob
            local spin = CFrame.Angles(0, spinDir * dt * (2.5 + selectedIdx * 0.4), 0)
            local bob  = Vector3.new(0, math.sin(t * 4) * 0.08, 0)
            root.CFrame = CFrame.new(root.Position + bob) * (root.CFrame - root.CFrame.Position) * spin
        end)
        -- Store as a sentinel so stopFunnyDance() can clean up
        funnyDanceTrack = "PHYS"
    end

    local function applyDance(char)
        char = char or LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
        if funnyDanceTrack then
            if funnyDanceTrack == "PHYS" then
                stopPhysDance()
            else
                pcall(function() funnyDanceTrack:Stop(0) end)
            end
            funnyDanceTrack = nil
        end

        -- Strategy 1: Deep-scan the character's Animate LocalScript for any pre-existing
        -- Animation objects. The game's own Animate script loads these at a lower security
        -- level that the place restriction does not apply to.
        -- We try multiple folder name variants and recurse through all descendants.
        local function findNativeAnim()
            local animateScript = char:FindFirstChild("Animate")
            if not animateScript then return nil end
            -- Ordered preference: dance-specific folders ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ any folder ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ any descendant
            local danceVariants = {
                { "dance",  "dance2", "dance3"  },
                { "Dance",  "Dance2", "Dance3"  },
                { "emote",  "emote2", "emote3"  },
                { "Emote",  "Emote2", "Emote3"  },
            }
            for _, variants in ipairs(danceVariants) do
                local folderName = variants[selectedIdx] or variants[1]
                local folder = animateScript:FindFirstChild(folderName)
                if folder then
                    local anim = folder:FindFirstChildOfClass("Animation")
                    if anim then return anim end
                end
            end
            -- Fallback: any Animation anywhere inside Animate (covers non-standard games)
            for _, desc in ipairs(animateScript:GetDescendants()) do
                if desc:IsA("Animation") then return desc end
            end
            return nil
        end

        local nativeAnim = findNativeAnim()
        if nativeAnim then
            local ok, track = pcall(function() return animator:LoadAnimation(nativeAnim) end)
            if ok and track then
                track.Priority = Enum.AnimationPriority.Action4
                track.Looped   = true
                track:Play(0.15)
                funnyDanceTrack = track
                return
            end
        end

        -- Strategy 2: game:GetObjects()  - Â executor API that fetches the asset without
        -- appending the serverplaceid query param, bypassing the place restriction.
        local ok2, results = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(selectedId))
        end)
        if ok2 and results and results[1] and results[1]:IsA("Animation") then
            local ok3, track = pcall(function() return animator:LoadAnimation(results[1]) end)
            if ok3 and track then
                track.Priority = Enum.AnimationPriority.Action4
                track.Looped   = true
                track:Play(0.15)
                funnyDanceTrack = track
                return
            end
        end

        -- Strategy 3: Physics dance  - Â no animation system used at all. Spins and bobs the
        -- HumanoidRootPart every Heartbeat, which is replicated to the server. Always works.
        Library:Notify({ Title = "Funny Dance", Description = "Animation blocked by game  -  using physics dance instead.", Time = 3 })
        startPhysDance(char)
    end

    applyDance()

    -- Reapply automatically after character respawn
    funnyDanceConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.delay(0.5, function()
            if Toggles.FunnyDance and Toggles.FunnyDance.Value then
                selectedIdx = Options.DanceStyle and Options.DanceStyle.Value or 1
                selectedId  = DANCE_ANIM_IDS[selectedIdx] or DANCE_ANIM_IDS[1]
                if physDanceConn then stopPhysDance() end
                applyDance(newChar)
            end
        end)
    end)
end

-- ============================================
-- SERVER HOP
-- [ADDED v7.3] Join a different server
-- ============================================
serverHop = function()
    local placeId = game.PlaceId
    local servers = {}
    local req = syn and syn.request or http_request or request or httprequest

    if req then
        -- Alternate sort direction randomly each hop ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ different server pool every time
        local sortOrder = math.random(0, 1) == 0 and "Asc" or "Desc"
        local cursor = ""
        local maxPages = 3  -- Up to 300 servers fetched for a large random pool

        for _ = 1, maxPages do
            local url = "https://games.roblox.com/v1/games/" .. placeId
                .. "/servers/Public?sortOrder=" .. sortOrder .. "&limit=100"
                .. (cursor ~= "" and ("&cursor=" .. cursor) or "")

            local ok, response = pcall(req, { Url = url, Method = "GET" })
            if not ok or not response or not response.Body then break end

            local ok2, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(response.Body)
            end)
            if not ok2 or not data or not data.data then break end

            for _, server in ipairs(data.data) do
                -- Skip current server and fully-packed servers
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end

            -- Follow pagination cursor for Solt page
            local SoltCursor = data.SoltPageCursor
            if not SoltCursor or SoltCursor == "" or SoltCursor == "null" then break end
            cursor = tostring(SoltCursor)
        end
    end

    if #servers > 0 then
        -- Fisher-Yates shuffle ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ every server has equal probability, no bias toward
        -- servers that happen to appear first in the API response
        for i = #servers, 2, -1 do
            local j = math.random(1, i)
            servers[i], servers[j] = servers[j], servers[i]
        end
        TeleportService:TeleportToPlaceInstance(placeId, servers[1], LocalPlayer)
        Library:Notify({ Title = "Server Hop", Description = "Joining server " .. #servers .. " found", Time = 3 })
    else
        -- Fallback: force a fresh matchmake (will place in a different server)
        TeleportService:Teleport(placeId, LocalPlayer)
        Library:Notify({ Title = "Server Hop", Description = "No servers - matchmaking...", Time = 3 })
    end
end

-- ============================================
-- REJOIN
-- [IMPROVED v7.3.3] Reconnects to the exact same server instance.
-- Priority chain:
--   1. TeleportAsync + TeleportOptions.ServerInstanceId  (modern, most reliable)
--   2. TeleportToPlaceInstance                           (legacy fallback)
--   3. TeleportService:Teleport                          (matchmaking fallback)
-- ============================================
rejoinServer = function()
    local placeId = game.PlaceId
    local jobId   = game.JobId

    if not jobId or jobId == "" then
        -- No JobId means we can't target the exact server; fall back to matchmaking
        pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
        Library:Notify({ Title = "Rejoin", Description = "No JobId  -  rejoining via matchmaking...", Time = 3 })
        return
    end

    Library:Notify({ Title = "Rejoin", Description = "Rejoining server...", Time = 2 })

    -- Attempt 1: TeleportAsync with ServerInstanceId (Roblox recommended since 2022)
    -- This targets the same running server instance by its JobId.
    local ok1, err1 = pcall(function()
        local opts = Instance.new("TeleportOptions")
        opts.ServerInstanceId = jobId
        TeleportService:TeleportAsync(placeId, { LocalPlayer }, opts)
    end)
    if ok1 then return end
    warn("[Rejoin] TeleportAsync failed: " .. tostring(err1))

    -- Attempt 2: Legacy TeleportToPlaceInstance
    local ok2, err2 = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)
    if ok2 then return end
    warn("[Rejoin] TeleportToPlaceInstance failed: " .. tostring(err2))

    -- Attempt 3: Plain matchmaking teleport (server may be gone)
    pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
    Library:Notify({ Title = "Rejoin", Description = "Server unavailable  -  rejoining via matchmaking...", Time = 3 })
end

-- ============================================
-- REMOTE SPY
-- [ADDED v7.3] Log all remote calls for analysis
-- [FIXED v7.3.3] Uses hookfunction for proper method hooking
-- [IMPROVED v7.3.3+] Primary hook now uses Potassium's hookmetamethod:
--              hookmetamethod(game, "__namecall", hook) - safest, purpose-built
--              Fallback chain: hookfunction ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ setreadonly namecall ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ passive
-- ============================================

local remoteSpyConnections = {}
local oldFireServer = nil
local oldInvokeServer = nil

stopRemoteSpy = function()
    remoteSpyEnabled = false
    
    -- [FIX #5] hookfunction cannot be truly unhooked; we stop logging via remoteSpyEnabled.
    -- Setting these to nil removes our reference but the low-overhead hook wrapper remains.
    -- The wrapper already checks `remoteSpyEnabled` before logging, so no output occurs.
    oldFireServer = nil
    oldInvokeServer = nil
    
    -- Clean up connections
    for _, conn in ipairs(remoteSpyConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    remoteSpyConnections = {}
    
    Library:Notify({ Title = "Remote Spy", Description = "Disabled", Time = 2 })
end

startRemoteSpy = function()
    stopRemoteSpy()
    remoteSpyEnabled = true
    remoteSpyLogs = {}
    
    Library:Notify({ Title = "Remote Spy", Description = "ON | Check console (F9)", Time = 3 })
    
    -- Helper function to log remote calls
    local function logRemoteCall(remote, method, args)
        if not remoteSpyEnabled then return end
        
        -- Safely get remote info
        local success, name = pcall(function() return remote.Name end)
        local success2, path = pcall(function() return remote:GetFullName() end)
        local success3, className = pcall(function() return remote.ClassName end)
        
        local logEntry = {
            Type = success3 and className or "Unknown",
            Method = method,
            Name = success and name or "Unknown",
            Path = success2 and path or "Unknown",
            Args = args,
            Time = os.date("%H:%M:%S")
        }
        table.insert(remoteSpyLogs, logEntry)
        if #remoteSpyLogs > 100 then table.remove(remoteSpyLogs, 1) end
        
        -- Print to console with safe string conversion
        local argCount = args and #args or 0
        print(string.format("[RemoteSpy] %s.%s(%s) - %s", 
            success and name or "Unknown", method, 
            argCount > 0 and tostring(argCount) .. " args" or "no args",
            os.date("%H:%M:%S")))
    end
    
    -- Method 0: hookmetamethod (Potassium API)  - Â purpose-built, safest
    if hookmetamethod then
        local success, err = pcall(function()
            local originalNamecall
            originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if remoteSpyEnabled and (method == "FireServer" or method == "InvokeServer") then
                    logRemoteCall(self, method, {...})
                end
                return originalNamecall(self, ...)
            end))
            oldFireServer = originalNamecall  -- store original ref; logging toggled via remoteSpyEnabled
        end)
        if success then
            Library:Notify({ Title = "Remote Spy", Description = "ON | hookmetamethod hook", Time = 2 })
            return
        else
            warn("[RemoteSpy] hookmetamethod failed: " .. tostring(err))
        end
    end

    -- Method 1: hookfunction (second best)
    if hookfunction then
        local success, err = pcall(function()
            local tempRemote = Instance.new("RemoteEvent")
            local tempFunc = Instance.new("RemoteFunction")

            oldFireServer = hookfunction(tempRemote.FireServer, function(self, ...)
                if remoteSpyEnabled then logRemoteCall(self, "FireServer", {...}) end
                return oldFireServer(self, ...)
            end)

            oldInvokeServer = hookfunction(tempFunc.InvokeServer, function(self, ...)
                if remoteSpyEnabled then logRemoteCall(self, "InvokeServer", {...}) end
                return oldInvokeServer(self, ...)
            end)

            tempRemote:Destroy()
            tempFunc:Destroy()
        end)
        if success then
            Library:Notify({ Title = "Remote Spy", Description = "ON | hookfunction hook", Time = 2 })
            return
        else
            warn("[RemoteSpy] hookfunction failed: " .. tostring(err))
        end
    end

    -- Method 2: setreadonly namecall (fallback)
    if getrawmetatable and setreadonly then
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        local success, err = pcall(function()
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if remoteSpyEnabled and (method == "FireServer" or method == "InvokeServer") then
                    logRemoteCall(self, method, {...})
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end)
        if success then
            Library:Notify({ Title = "Remote Spy", Description = "ON | namecall hook", Time = 2 })
            return
        else
            warn("[RemoteSpy] namecall hook failed: " .. tostring(err))
            pcall(function()
                setreadonly(mt, false)
                mt.__namecall = oldNamecall
                setreadonly(mt, true)
            end)
        end
    end

    -- Method 3: Passive mode  - Â scan and list remotes only (no hooks available)
    Library:Notify({ Title = "Remote Spy", Description = "ON | Passive mode", Time = 4 })
    
    -- List all known remotes
    if Remotes then
        print("[RemoteSpy] === Available Remotes ===")
        for _, folder in ipairs(Remotes:GetChildren()) do
            for _, remote in ipairs(folder:GetChildren()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    print(string.format("[RemoteSpy] %s: %s", remote.ClassName, remote:GetFullName()))
                    table.insert(remoteSpyLogs, {
                        Type = remote.ClassName,
                        Method = "Discovered",
                        Name = remote.Name,
                        Path = remote:GetFullName(),
                        Args = {},
                        Time = os.date("%H:%M:%S")
                    })
                end
            end
        end
        print("[RemoteSpy] === End of Remote List ===")
    end
end

-- ============================================
-- AUTO PICKUP  (FE Multi-Vector, rebuilt)
-- Four independent pickup strategies, each toggle-able:
--
--  A  Remote      -  FireServer(PickUpItem + AdjustBackpack) directly.
--                  Fast and clean; works when the server is lenient on
--                  distance checks or the item is already nearby.
--
--  B  Touch       -  firetouchinterest(hrp, itemPart)  - Â simulates the
--                  player's HumanoidRootPart physically touching the
--                  item part. Fires the Touched handler server-side in
--                  Potassium/synapse-compatible executors.
--
--  C  Prompt      -  fireproximityprompt(prompt)  - Â triggers ProximityPrompt
--                  on items that expose one instead of (or in addition to)
--                  a Touched handler.
--
--  D  Teleport    -  Moves the item's BaseParts to the player's CFrame
--                  client-side before firing remotes + touch. Bypasses
--                  any server-side distance check because the item is
--                  physically on top of the player when the remote fires.
--                  Most powerful method; enable as first step to test.
--
end
_initCombatUtils()

-- ============================================
-- AUTO PICKUP  (FE Multi-Vector, rebuilt)
-- ============================================
local _checkFarmToggle

local function _initAutoPickup()
local autoPickupActive  = false
local autoPickupThread  = nil
local autoPickupAttempts = {}  -- [item ref] = last attempt tick

local _pickupCirclePart = nil
local _pickupCircleRenderConn = nil
local function _updatePickupVisualCircle(show, radius)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not show or not hrp then
        if _pickupCirclePart and _pickupCirclePart.Parent then
            _pickupCirclePart.Parent = nil
        end
        if _pickupCircleRenderConn then
            _pickupCircleRenderConn:Disconnect()
            _pickupCircleRenderConn = nil
        end
        return
    end

    if not _pickupCirclePart or not _pickupCirclePart.Parent then
        _pickupCirclePart = Instance.new("Part")
        _pickupCirclePart.Name = "NX_PickupRadiusCircle"
        _pickupCirclePart.Shape = Enum.PartType.Block
        _pickupCirclePart.Anchored = true
        _pickupCirclePart.CanCollide = false
        _pickupCirclePart.CanTouch = false
        _pickupCirclePart.CanQuery = false
        _pickupCirclePart.CastShadow = false
        _pickupCirclePart.Massless = true
        _pickupCirclePart.Transparency = 1 -- Fully invisible Part
        _pickupCirclePart.Parent = workspace.Terrain

        -- SurfaceGui on bottom face to draw the ring
        local gui = Instance.new("SurfaceGui")
        gui.Name = "CircleGui"
        gui.Face = Enum.NormalId.Top
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        gui.AlwaysOnTop = false
        gui.LightInfluence = 0
        gui.Brightness = 1
        gui.Parent = _pickupCirclePart

        local frame = Instance.new("Frame")
        frame.Name = "Ring"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1 -- No fill
        frame.BorderSizePixel = 0
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0) -- Makes it a circle
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 230, 255)
        stroke.Thickness = 5
        stroke.Transparency = 0.15
        stroke.Parent = frame
    end

    -- Update Part size (square slab = diameter x diameter)
    local diameter = radius * 2
    _pickupCirclePart.Size = Vector3.new(diameter, 0.01, diameter)

    -- Smooth per-frame tracking via RenderStepped
    if not _pickupCircleRenderConn then
        _pickupCircleRenderConn = RunService.RenderStepped:Connect(function()
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r and _pickupCirclePart and _pickupCirclePart.Parent then
                _pickupCirclePart.CFrame = CFrame.new(r.Position.X, r.Position.Y - 3, r.Position.Z)
            end
        end)
    end
end

stopAutoPickup = function()
    autoPickupActive = false
    if autoPickupThread then
        pcall(function() task.cancel(autoPickupThread) end)
        autoPickupThread = nil
    end
    autoPickupAttempts = {}
    if _pickupCircleRenderConn then
        _pickupCircleRenderConn:Disconnect()
        _pickupCircleRenderConn = nil
    end
    if _pickupCirclePart and _pickupCirclePart.Parent then
        _pickupCirclePart.Parent = nil
    end
end

local function _shouldSkipAutoPickupItem(itemName)
    local cat = itemCategoryLookup[itemName]
    if cat == "Food" then
        local doAutoUse = Toggles.AutoUse and Toggles.AutoUse.Value
        local doAutoEat = Toggles.AutoEat and Toggles.AutoEat.Value
        if doAutoUse or doAutoEat then
            return true
        end
    end
    return false
end

local AUTO_PICKUP_ADJUST_ONLY = {
    ["Chips"] = true, ["Carrot"] = true, ["Bloxiade"] = true, ["Beans"] = true, ["MRE"] = true, ["Bloxy Cola"] = true,
    ["Nuclear Fuel"] = true, ["Refined Fuel"] = true, ["Fuel"] = true,
    ["Power Armor Arm"] = true, ["Power Armor Core"] = true, ["Radio Tower Part"] = true,
    ["AC"] = true, ["Battery"] = true, ["Battery Pack"] = true, ["Bucket"] = true, ["Dumbell"] = true, ["Exhaust Pipe"] = true,
    ["Reactor Component"] = true, ["Refined Metal"] = true, ["Satellite Dish"] = true, ["Scrap"] = true, ["Screws"] = true,
    ["Spatula"] = true, ["Tray"] = true, ["TV"] = true, ["Watch"] = true, ["Zombie Heart"] = true,
    ["Airstrike"] = true, ["Attack Order"] = true, ["Call of the Dead"] = true, ["Summon Brute"] = true,
    ["Summon Zombies"] = true, ["Taunt"] = true, ["The Future"] = true, ["The Past"] = true, ["The Present"] = true,
}

local function _fireAutoPickupRemotes(item, adjustOnly)
    if not item or not item.Parent then return end
    item = getDroppedItemRoot(item)
    if not item or not item.Parent then return end

    if not adjustOnly and item:IsA("Model") then
        local pickupR = getPickUpRemote()
        if pickupR then
            pcall(function() pickupR:FireServer(item) end)
        end
    end

    local adjustR = getAdjustBackpackRemote()
    if adjustR and item:IsA("Model") then
        local n = string.lower(item.Name)
        local isWeapon = n:find("gun") or n:find("rifle") or n:find("shotgun") or n:find("pistol") or n:find("revolver") or n:find("sniper") or n:find("smg") or n:find("ak") or n:find("m4") or n:find("katana") or n:find("sword") or n:find("bat") or n:find("axe") or n:find("hammer") or n:find("knife") or n:find("machete") or n:find("glock") or n:find("magnum") or n:find("sledge")
        if not isWeapon then
            pcall(function() adjustR:FireServer(item) end)
        end
    end
end

local function _burstAutoPickupRemotes(item, adjustOnly)
    _fireAutoPickupRemotes(item, adjustOnly)
    task.delay(0.12, function()
        _fireAutoPickupRemotes(item, adjustOnly)
    end)
    task.delay(0.28, function()
        _fireAutoPickupRemotes(item, adjustOnly)
    end)
end

local function _isAutoPickupCandidate(item, allItems, whitelist)
    if not item or not item.Parent then return false end
    if Players:GetPlayerFromCharacter(item) then return false end
    if _shouldSkipAutoPickupItem(item.Name) then return false end

    if allItems then
        return item:IsA("Model")
            or item:IsA("BasePart")
            or item:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
    end

    return whitelist[item.Name] == true
end

local function _getNearbyAutoPickupCandidates(hrp, radius, allItems, whitelist)
    local candidates = {}
    local seen = {}
    if not droppedItemsFolder or not hrp then return candidates end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    overlapParams.FilterDescendantsInstances = { droppedItemsFolder }
    overlapParams.MaxParts = 80

    local parts = workspace:GetPartBoundsInRadius(hrp.Position, radius, overlapParams)

    for _, part in ipairs(parts) do
        local candidate = getDroppedItemRoot(part)
        if candidate and not seen[candidate] then
            if candidate.Parent == droppedItemsFolder then
                if _isAutoPickupCandidate(candidate, allItems, whitelist) then
                    table.insert(candidates, candidate)
                    seen[candidate] = true
                end
            end
        end
    end

    return candidates
end

startAutoPickup = function()
    stopAutoPickup()
    autoPickupActive = true

    autoPickupThread = task.spawn(function()
        while autoPickupActive and Toggles.AutoPickup and Toggles.AutoPickup.Value do
            local ok, err = pcall(function()
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp or not droppedItemsFolder then
                    task.wait(0.25)
                    return
                end

                local myPos      = hrp.Position
                local radius     = Options.AutoPickupRadius and Options.AutoPickupRadius.Value or 20
                local allItems   = Toggles.AutoPickupAll and Toggles.AutoPickupAll.Value
                local whitelist  = Options.AutoPickupWhitelist and Options.AutoPickupWhitelist.Value or {}

                _updatePickupVisualCircle(true, radius)

                -- Pause inside workspace.Map.Tiles.Center (any height: above, on, below).
                local inCenter = false
                local centerTile = Workspace:FindFirstChild("Map")
                    and Workspace.Map:FindFirstChild("Tiles")
                    and Workspace.Map.Tiles:FindFirstChild("Center")
                if centerTile then
                    local okBox, cf, size = pcall(function() return centerTile:GetBoundingBox() end)
                    if okBox and cf and size then
                        local localPos = cf:PointToObjectSpace(myPos)
                        if math.abs(localPos.X) <= size.X / 2 and math.abs(localPos.Z) <= size.Z / 2 then
                            inCenter = true
                        end
                    end
                end

                if inCenter then
                    task.wait(0.25)
                    return
                end

                -- Determine which methods are enabled (default all on if toggles not yet created)
                local useRemote = not Toggles.AutoPickupMethodRemote or Toggles.AutoPickupMethodRemote.Value
                local useTouch  = not Toggles.AutoPickupMethodTouch or Toggles.AutoPickupMethodTouch.Value
                local usePrompt = not Toggles.AutoPickupMethodPrompt or Toggles.AutoPickupMethodPrompt.Value

                -- SPATIAL QUERY: Only process items physically inside the circle radius! Zero iteration over the rest of the map!
                local nearbyItems = _getNearbyAutoPickupCandidates(hrp, radius, allItems, whitelist)

                for _, item in ipairs(nearbyItems) do
                    if not autoPickupActive then break end
                    if item.Parent then
                        local itemPos, mainPart = getItemPickupPosition(item)
                        if itemPos then
                            local now = tick()
                            if not (autoPickupAttempts[item] and (now - autoPickupAttempts[item]) < 0.35) then
                                autoPickupAttempts[item] = now
                                local adjustOnly = AUTO_PICKUP_ADJUST_ONLY[item.Name] == true

                                if useRemote or adjustOnly then
                                    _burstAutoPickupRemotes(item, adjustOnly)
                                end

                                if useTouch and not adjustOnly and mainPart then
                                    pcall(function()
                                        if firetouchinterest then
                                            firetouchinterest(hrp, mainPart, 0)
                                            task.delay(0.05, function()
                                                if hrp and hrp.Parent and mainPart and mainPart.Parent then
                                                    pcall(function() firetouchinterest(hrp, mainPart, 1) end)
                                                end
                                            end)
                                        end
                                    end)
                                end

                                if usePrompt and not adjustOnly then
                                    pcall(function()
                                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt and fireproximityprompt then
                                            prompt.RequiresLineOfSight = false
                                            prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, radius + 5)
                                            prompt.HoldDuration = 0
                                            fireproximityprompt(prompt)
                                        end
                                    end)
                                end

                                task.wait()
                            end
                        end
                    end
                end

                for itemRef in pairs(autoPickupAttempts) do
                    if not itemRef.Parent then
                        autoPickupAttempts[itemRef] = nil
                    end
                end

                task.wait(0.25)
            end)
            if not ok then
                warn("[SolanaHub] AutoPickup loop error: " .. tostring(err))
                task.wait(0.5)
            end
        end

        autoPickupActive = false
        if _pickupCirclePart and _pickupCirclePart.Parent then _pickupCirclePart.Parent = nil end
    end)
end

-- REPAIR AURA
stopRepairAura = function()
    if repairAuraConn then
        repairAuraConn:Disconnect()
        repairAuraConn = nil
    end
end

startRepairAura = function()
    stopRepairAura()
    local lastFire = 0

    repairAuraConn = RunService.Heartbeat:Connect(function()
        if not Toggles.RepairAura or not Toggles.RepairAura.Value then return end

        local rate     = Options.RepairAuraRate and Options.RepairAuraRate.Value or 1
        local interval = 1 / rate
        local now      = tick()
        if now - lastFire < interval then return end

        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or tool.Name ~= "Repair Hammer" then return end

        local repairRemote = tool:FindFirstChild("Repair")
        if not repairRemote then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local myPos   = hrp.Position
        local maxDist = Options.RepairAuraRange and Options.RepairAuraRange.Value or 30

        if not structuresFolder then return end
        local nearest     = nil
        local nearestDist = math.huge
        for _, child in ipairs(structuresFolder:GetDescendants()) do
            if child:IsA("Model") then
                local part = child.PrimaryPart or getItemMainPart(child)
                if part then
                    local dist = (myPos - part.Position).Magnitude
                    if dist <= maxDist and dist < nearestDist then
                        nearestDist = dist
                        nearest     = child
                    end
                end
            end
        end

        if nearest then
            lastFire = now
            pcall(function()
                repairRemote:FireServer(nearest)
            end)
        end
    end)
end

end
_initAutoPickup()

local function _initAutoFarmEngine()

-- ============================================================
-- AUTO FARM ENGINE (ported from zombie.txt)
-- ============================================================

-- Item & Zombie lists
local ALL_ITEM_NAMES_FARM = {
    "Bandage","Medkit","Shells","Barbed Wire","Grenade","Knife","Beans","Bloxiade",
    "Bloxy Cola","Chips","Long Ammo","Medium Ammo","Pistol Ammo","Revolver","Katana",
    "Molotov","Compound S","Uzi","Rifle","Hatchet","Riot Shield","Fire Axe","Compound I",
    "Crowbar","Dumbell","Refined Fuel","Fuel","Scrap","Battery","Battery Pack",
    "Screws","Spatula","Tray","AC","Satellite Dish","Refined Metal","Watch","MRE","TV","Bucket"
}
local ALL_ITEM_SET_FARM = {}
for _, n in ipairs(ALL_ITEM_NAMES_FARM) do ALL_ITEM_SET_FARM[n] = true end

-- World cache (weak refs)
local WorldItemsCache_F  = setmetatable({}, {__mode="k"})
local ActiveZombiesCache_F = setmetatable({}, {__mode="k"})
local FarmCacheReady = false

-- State
local farmState = {
    BagFullLatched = false,
    FarmItemTarget  = nil,
    ReactivateFeatures = nil,
    ConsecutivePickupFails = 0,
}

-- Config bridge  - Â baca dari Toggles & Options
local function getFarmCfg()
    return {
        AUTO_Farm       = Toggles.AutoFarmZombies  and Toggles.AutoFarmZombies.Value  or false,
        AUTO_FarmItems  = Toggles.AutoFarmItems    and Toggles.AutoFarmItems.Value    or false,
        AUTO_ReturnGen  = Toggles.AutoReturnGenerator and Toggles.AutoReturnGenerator.Value or false,
        AUTO_FarmRadius = Options.FarmRadius       and Options.FarmRadius.Value       or 400,
        AUTO_FarmHeight = Options.FarmHoverHeight  and Options.FarmHoverHeight.Value  or 8,
        AUTO_FarmTweenSpeed = Options.FarmMoveSpeed and Options.FarmMoveSpeed.Value   or 1,
        AUTO_FarmSafeZone = Options.FarmSafeZone   and Options.FarmSafeZone.Value    or 15,
    }
end

-- Helpers
local function _isZombieNode(model)
    if typeof(model) ~= "Instance" or not model:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    if model == LocalPlayer.Character then return false end
    local hum = model:FindFirstChildWhichIsA("Humanoid")
    if hum then return true end
    local name = model.Name:lower()
    return name:find("zombie") or name:find("runner") or name:find("crawler") or
           name:find("riot") or name:find("infected") or name:find("boss") or name:find("mutant")
end

local function _getItemPartF(item)
    if not item then return nil end
    if item:IsA("BasePart") then return item end
    local p = item:FindFirstChildWhichIsA("BasePart")
    if p then return p end
    if item:IsA("Model") then return item.PrimaryPart end
    return nil
end

local function _getAllItemsF()
    local r = {}
    local seen = {}
    if droppedItemsFolder then
        for _, obj in ipairs(droppedItemsFolder:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and not seen[obj] then
                if ALL_ITEM_SET_FARM[obj.Name] or obj:FindFirstChildWhichIsA("ProximityPrompt", true) then
                    table.insert(r, obj)
                    seen[obj] = true
                end
            end
        end
        return r
    end

    for item in pairs(WorldItemsCache_F) do
        if item and item.Parent and not seen[item] then table.insert(r, item)
        elseif not item or not item.Parent then WorldItemsCache_F[item] = nil end
    end
    return r
end

local function _shouldSkipAutoPickupItem(itemName)
    local cat = itemCategoryLookup[itemName]
    if cat == "Food" then
        local doAutoUse = Toggles.AutoUse and Toggles.AutoUse.Value
        local doAutoEat = Toggles.AutoEat and Toggles.AutoEat.Value
        if doAutoUse or doAutoEat then
            return true
        end
    end
    return false
end

local AUTO_PICKUP_ADJUST_ONLY = {
    ["Chips"] = true, ["Carrot"] = true, ["Bloxiade"] = true, ["Beans"] = true, ["MRE"] = true, ["Bloxy Cola"] = true,
    ["Nuclear Fuel"] = true, ["Refined Fuel"] = true, ["Fuel"] = true,
    ["Power Armor Arm"] = true, ["Power Armor Core"] = true, ["Radio Tower Part"] = true,
    ["AC"] = true, ["Battery"] = true, ["Battery Pack"] = true, ["Bucket"] = true, ["Dumbell"] = true, ["Exhaust Pipe"] = true,
    ["Reactor Component"] = true, ["Refined Metal"] = true, ["Satellite Dish"] = true, ["Scrap"] = true, ["Screws"] = true,
    ["Spatula"] = true, ["Tray"] = true, ["TV"] = true, ["Watch"] = true, ["Zombie Heart"] = true,
    ["Airstrike"] = true, ["Attack Order"] = true, ["Call of the Dead"] = true, ["Summon Brute"] = true,
    ["Summon Zombies"] = true, ["Taunt"] = true, ["The Future"] = true, ["The Past"] = true, ["The Present"] = true,
}

local function _fireAutoPickupRemotes(item, adjustOnly)
    if not item or not item.Parent then return end
    item = getDroppedItemRoot(item)
    if not item or not item.Parent then return end

    if not adjustOnly and item:IsA("Model") then
        local pickupR = getPickUpRemote()
        if pickupR then
            pcall(function() pickupR:FireServer(item) end)
        end
    end

    local adjustR = getAdjustBackpackRemote()
    if adjustR and item:IsA("Model") then
        local n = string.lower(item.Name)
        local isWeapon = n:find("gun") or n:find("rifle") or n:find("shotgun") or n:find("pistol") or n:find("revolver") or n:find("sniper") or n:find("smg") or n:find("ak") or n:find("m4") or n:find("katana") or n:find("sword") or n:find("bat") or n:find("axe") or n:find("hammer") or n:find("knife") or n:find("machete") or n:find("glock") or n:find("magnum") or n:find("sledge")
        if not isWeapon then
            pcall(function() adjustR:FireServer(item) end)
        end
    end
end

local function _burstAutoPickupRemotes(item, adjustOnly)
    _fireAutoPickupRemotes(item, adjustOnly)
    task.delay(0.12, function()
        _fireAutoPickupRemotes(item, adjustOnly)
    end)
    task.delay(0.28, function()
        _fireAutoPickupRemotes(item, adjustOnly)
    end)
end

local function _isAutoPickupCandidate(item, allItems, whitelist)
    if not item or not item.Parent then return false end
    if Players:GetPlayerFromCharacter(item) then return false end
    if _shouldSkipAutoPickupItem(item.Name) then return false end

    if allItems then
        return item:IsA("Model")
            or item:IsA("BasePart")
            or item:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
    end

    return whitelist[item.Name] == true
end

local function _getNearbyAutoPickupCandidates(hrp, radius, allItems, whitelist)
    local candidates = {}
    local seen = {}
    if not droppedItemsFolder or not hrp then return candidates end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Include
    overlapParams.FilterDescendantsInstances = { droppedItemsFolder }
    overlapParams.MaxParts = 80

    local parts = workspace:GetPartBoundsInRadius(hrp.Position, radius, overlapParams)

    for _, part in ipairs(parts) do
        local itemModel = getDroppedItemRoot(part)

        if itemModel and itemModel.Parent and not seen[itemModel] then
            seen[itemModel] = true
            if _isAutoPickupCandidate(itemModel, allItems, whitelist) then
                table.insert(candidates, itemModel)
            end
        end
    end

    return candidates
end

local function _getActiveZombiesF()
    local r = {}
    for z in pairs(ActiveZombiesCache_F) do
        if z and z.Parent then table.insert(r, z)
        else ActiveZombiesCache_F[z] = nil end
    end
    return r
end

-- Init world cache
task.spawn(function()
    for _, child in ipairs(Workspace:GetDescendants()) do
        if ALL_ITEM_SET_FARM[child.Name] and not Players:GetPlayerFromCharacter(child) then
            WorldItemsCache_F[child] = true
        end
        if _isZombieNode(child) then ActiveZombiesCache_F[child] = true end
    end
    FarmCacheReady = true

    Workspace.DescendantAdded:Connect(function(child)
        if ALL_ITEM_SET_FARM[child.Name] and not Players:GetPlayerFromCharacter(child) then
            WorldItemsCache_F[child] = true
        end
        if child:IsA("Model") then
            task.delay(0.1, function()
                if child and child.Parent and _isZombieNode(child) then
                    ActiveZombiesCache_F[child] = true
                end
            end)
        end
    end)
    Workspace.DescendantRemoving:Connect(function(child)
        WorldItemsCache_F[child]  = nil
        ActiveZombiesCache_F[child] = nil
    end)
end)

-- Bag-full detector (sadap Popup remote)
task.spawn(function()
    pcall(function()
        local rem = ReplicatedStorage:WaitForChild("Remotes", 10)
        if not rem then return end
        local rep = rem:WaitForChild("Replication", 10)
        if not rep then return end

        local function flattenMsg(value, depth)
            depth = depth or 0
            if depth > 2 then return "" end
            local t = type(value)
            if t == "string" then return value end
            if t == "number" or t == "boolean" then return tostring(value) end
            if t == "table" then
                local parts = {}
                for _, v in pairs(value) do
                    local s = flattenMsg(v, depth + 1)
                    if s ~= "" then table.insert(parts, s) end
                end
                return table.concat(parts, " ")
            end
            return ""
        end

        local function isBagFullMsg(msg)
            local hasFullWord =
                string.find(msg, " full", 1, true)
                or string.find(msg, "penuh", 1, true)
                or string.find(msg, "no space", 1, true)
                or string.find(msg, "cannot carry", 1, true)

            local hasBagWord =
                string.find(msg, "backpack", 1, true)
                or string.find(msg, "inventory", 1, true)
                or string.find(msg, "bag", 1, true)
                or string.find(msg, "ransel", 1, true)
                or string.find(msg, "tas", 1, true)

            -- Avoid false positives like generic "penuh"/"full" not related to bag.
            if hasFullWord and hasBagWord then return true end
            if string.find(msg, "backpack full", 1, true) then return true end
            if string.find(msg, "inventory full", 1, true) then return true end
            if string.find(msg, "ransel penuh", 1, true) then return true end
            if string.find(msg, "tas penuh", 1, true) then return true end
            return false
        end

        local function isBagReadyMsg(msg)
            if string.find(msg, "backpack ready", 1, true) then return true end
            if string.find(msg, "ransel siap", 1, true) then return true end
            if string.find(msg, "space available", 1, true) then return true end
            if string.find(msg, "inventory empty", 1, true) then return true end
            if string.find(msg, "tas kosong", 1, true) then return true end
            return false
        end

        local function onBagPopup(message)
            local msg = string.lower(flattenMsg(message))
            if msg == "" then return end
            if isBagFullMsg(msg) then
                if not _G.STA_BagFull then
                    _G.STA_BagFull = true
                    farmState.ConsecutivePickupFails = 0
                    Library:Notify({ Title = "Backpack Full", Description = "Auto Farm paused temporarily.", Time = 3 })
                end
            elseif isBagReadyMsg(msg) then
                if _G.STA_BagFull then
                    _G.STA_BagFull = false
                    farmState.ConsecutivePickupFails = 0
                    Library:Notify({ Title = "Backpack Ready", Description = "Auto Farm resumed!", Time = 3 })
                end
            end
        end

        local popup = rep:FindFirstChild("Popup")
        if popup and popup:IsA("RemoteEvent") then
            popup.OnClientEvent:Connect(onBagPopup)
        end
        for _, obj in ipairs(rep:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local n = string.lower(obj.Name)
                if n:find("popup", 1, true) or n:find("notify", 1, true) or n:find("message", 1, true) then
                    obj.OnClientEvent:Connect(onBagPopup)
                end
            end
        end
    end)
end)

-- AI Pathfinding
local AIPATH_F      = game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,AgentCanClimb=true})
local _farmTarget   = nil
local _farmBlacklist = {}
local _lastTargetScan = 0
local _lastPathCalc  = 0
local _pathWaypoints = {}
local _pathIndex     = 1
local _pathTargetPos = Vector3.zero
local _lastFarmTime  = 0
local _lastFarmDist  = 0
local _cachedGenerator_F = nil

-- Find generator
local function _findGenerator()
    local structures = Workspace:FindFirstChild("Structures")
    local generatorFolder = structures and structures:FindFirstChild("Generator")
    local generatorModel = generatorFolder and generatorFolder:FindFirstChild("GeneratorModel")
    if generatorModel then
        _cachedGenerator_F = generatorModel
        return generatorModel
    end
    if _cachedGenerator_F and _cachedGenerator_F.Parent then return _cachedGenerator_F end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = obj.Name:lower()
            if n == "generator" or n == "safegen" or n == "basegen" then
                _cachedGenerator_F = obj; return obj
            end
        end
    end
    return nil
end

local function _getGeneratorStandPosition(root)
    local gen = _findGenerator()
    if not gen then return nil end

    local standOffset = 3
    if root and root:IsA("BasePart") then
        standOffset = math.max(3, root.Size.Y * 0.5 + 1.5)
    end

    if gen:IsA("Model") then
        local cf, size = gen:GetBoundingBox()
        return Vector3.new(cf.Position.X, cf.Position.Y + (size.Y * 0.5) + standOffset, cf.Position.Z)
    elseif gen:IsA("BasePart") then
        return gen.Position + Vector3.new(0, (gen.Size.Y * 0.5) + standOffset, 0)
    end

    return nil
end

local function _tryFarmPickupItem(item, myRoot)
    if not item or not item.Parent then return false end
    item = getDroppedItemRoot(item)
    if not item or not item.Parent then return false end
    local pt = _getItemPartF(item)

    local pickupR = getPickUpRemote()
    local adjustR = getAdjustBackpackRemote()
    
    local itemName = item.Name
    local noPickupRemote = {
        ["Chips"] = true, ["Carrot"] = true, ["Bloxiade"] = true, ["Beans"] = true, ["MRE"] = true, ["Bloxy Cola"] = true,
        ["Nuclear Fuel"] = true, ["Refined Fuel"] = true, ["Fuel"] = true,
        ["Power Armor Arm"] = true, ["Power Armor Core"] = true, ["Radio Tower Part"] = true,
        ["AC"] = true, ["Battery"] = true, ["Battery Pack"] = true, ["Bucket"] = true, ["Dumbell"] = true, ["Exhaust Pipe"] = true,
        ["Reactor Component"] = true, ["Refined Metal"] = true, ["Satellite Dish"] = true, ["Scrap"] = true, ["Screws"] = true,
        ["Spatula"] = true, ["Tray"] = true, ["TV"] = true, ["Watch"] = true, ["Zombie Heart"] = true,
        ["Airstrike"] = true, ["Attack Order"] = true, ["Call of the Dead"] = true, ["Summon Brute"] = true,
        ["Summon Zombies"] = true, ["Taunt"] = true, ["The Future"] = true, ["The Past"] = true, ["The Present"] = true,
    }

    -- Try server remotes first. ONLY fire PickUpItem if it's not in the blacklist.
    if pickupR and item:IsA("Model") and not noPickupRemote[itemName] then pcall(function() pickupR:FireServer(item) end) end
    if adjustR and item:IsA("Model") then
        local n = string.lower(item.Name)
        local isWeapon = n:find("gun") or n:find("rifle") or n:find("shotgun") or n:find("pistol") or n:find("revolver") or n:find("sniper") or n:find("smg") or n:find("ak") or n:find("m4") or n:find("katana") or n:find("sword") or n:find("bat") or n:find("axe") or n:find("hammer") or n:find("knife") or n:find("machete") or n:find("glock") or n:find("magnum") or n:find("sledge")
        if not isWeapon then
            pcall(function() adjustR:FireServer(item) end)
        end
    end


    -- Prompt fallback for E-interact items.
    pcall(function()
        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and fireproximityprompt then 
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = 50
            prompt.HoldDuration = 0 -- [FIX] Paksa durasi menjadi 0 agar tidak ter-cancel saat di-spam tiap 0.25 detik
            fireproximityprompt(prompt) 
        end
    end)

    -- Touch fallback (Non-blocking)
    if pt and myRoot and firetouchinterest then
        pcall(function() firetouchinterest(myRoot, pt, 0) end)
        task.delay(0.05, function()
            if myRoot and pt and pt.Parent then
                pcall(function() firetouchinterest(myRoot, pt, 1) end)
            end
        end)
    end

    -- Langsung return true tanpa memblokir Heartbeat
    return true
end

-- Farm Heartbeat loop
local farmHeartbeatConn = nil
local returnGenActive   = false

local function _finishReturnGenerator(lRoot)
    _G.STA_BagFull = false
    farmState.ConsecutivePickupFails = 0
    farmState.ReturnGenArrivedAt = nil
    farmState.ReturnGenNotifyAt = nil
    returnGenActive = false
    pcall(function()
        if lRoot and lRoot:FindFirstChild("NXFARM_BV") then lRoot.NXFARM_BV:Destroy() end
        if lRoot and lRoot:FindFirstChild("NXFARM_GY") then lRoot.NXFARM_GY:Destroy() end
        if lRoot and lRoot:FindFirstChild("NXFARM_WALK_BV") then lRoot.NXFARM_WALK_BV:Destroy() end
    end)
    Library:Notify({ Title = "Auto Return Gen", Description = "Wait finished. Auto Farm resumed.", Time = 2 })
    return true
end

local function _waitAtGeneratorThenResume(lRoot)
    local now = tick()
    if not farmState.ReturnGenArrivedAt then
        farmState.ReturnGenArrivedAt = now
        farmState.ReturnGenNotifyAt = now
        Library:Notify({ Title = "Auto Return Gen", Description = "Arrived. Waiting 5 seconds...", Time = 2 })
    end

    if now - farmState.ReturnGenArrivedAt >= 5 then
        return _finishReturnGenerator(lRoot)
    end

    return false
end

local function _isAcrossBorder(targetPos, myPos)
    local borderFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Border")
    if not borderFolder then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Include
    rayParams.FilterDescendantsInstances = {borderFolder}
    local dir = (targetPos - myPos)
    local hit = Workspace:Raycast(myPos, dir, rayParams)
    return hit ~= nil
end

stopAutoFarmEngine = function()
    if farmHeartbeatConn then farmHeartbeatConn:Disconnect(); farmHeartbeatConn = nil end
    -- Cleanup BodyVelocity/Gyro
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            if root:FindFirstChild("NXFARM_BV") then root.NXFARM_BV:Destroy() end
            if root:FindFirstChild("NXFARM_WALK_BV") then root.NXFARM_WALK_BV:Destroy() end
            if root:FindFirstChild("NXFARM_GY") then root.NXFARM_GY:Destroy() end
            root.Anchored = false
        end
    end)
end

startAutoFarmEngine = function()
    stopAutoFarmEngine()

    farmHeartbeatConn = RunService.Heartbeat:Connect(function(dt)
        local cfg = getFarmCfg()
        local active = cfg.AUTO_Farm or cfg.AUTO_FarmItems or cfg.AUTO_ReturnGen or returnGenActive
        if not active then
            -- Cleanup jika semua fitur off
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local bv = root:FindFirstChild("NXFARM_BV"); if bv then bv:Destroy() end
                local bvw = root:FindFirstChild("NXFARM_WALK_BV"); if bvw then bvw:Destroy() end
                local gy = root:FindFirstChild("NXFARM_GY"); if gy then gy:Destroy() end
            end
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local lRoot = char:FindFirstChild("HumanoidRootPart")
        local lHum  = char:FindFirstChildOfClass("Humanoid")
        if not lRoot or not lHum or lHum.Health <= 0 then return end

        local radius     = math.max(1, cfg.AUTO_FarmRadius)
        local farmSpeed  = math.max(0.1, cfg.AUTO_FarmTweenSpeed)
        local hoverH     = cfg.AUTO_FarmHeight

        local now = tick()
        
        local genPos = nil
        local gen = _findGenerator()
        if gen then
            if gen:IsA("Model") then
                local genCf = gen:GetBoundingBox()
                genPos = genCf.Position
            elseif gen:IsA("BasePart") then
                genPos = gen.Position
            end
        end

        -- Auto Return Generator logic
        if cfg.AUTO_ReturnGen and (_G.STA_BagFull or returnGenActive) then
            returnGenActive = true
        elseif not _G.STA_BagFull then
            farmState.ReturnGenArrivedAt = nil
            returnGenActive = false
        end

        -- Cari target setiap 0.5 detik
        if now - _lastTargetScan > 0.5 then
            _lastTargetScan = now
            _farmTarget = nil
            farmState.FarmItemTarget = nil

            if cfg.AUTO_Farm then
                local best, bestDist = nil, radius
                for _, z in ipairs(_getActiveZombiesF()) do
                    local zRoot = z:FindFirstChild("HumanoidRootPart")
                    local zHum  = z:FindFirstChildOfClass("Humanoid")
                    if zRoot and zHum and zHum.Health > 0 then
                        if not (_farmBlacklist[z] and now - _farmBlacklist[z] < 10) then
                            if not _isAcrossBorder(zRoot.Position, lRoot.Position) then
                                local d = (zRoot.Position - lRoot.Position).Magnitude
                                if d < bestDist then bestDist = d; best = z end
                            end
                        end
                    end
                end
                _farmTarget = best
            end

            -- Auto Farm Items (hanya jika tidak ada zombie target dan tas tidak penuh)
            if not _farmTarget and cfg.AUTO_FarmItems and not _G.STA_BagFull then
                local oldItem = farmState.FarmItemTarget
                -- [FIX] Kunci target lama agar karakter tidak plin-plan (pindah target di tengah jalan)
                if oldItem and oldItem.Parent and not (_farmBlacklist[oldItem] and now - _farmBlacklist[oldItem] < 10) then
                    farmState.FarmItemTarget = oldItem
                else
                    local best, bestDist = nil, radius
                    local pickupAll    = Toggles.AutoPickupAll and Toggles.AutoPickupAll.Value or false
                    local pickupFilter = Options.AutoPickupWhitelist and Options.AutoPickupWhitelist.Value or {}
                    
                    local filterSet = {}
                    if type(pickupFilter) == "table" then
                        local hasStringKey = false
                        for k, val in pairs(pickupFilter) do
                            if type(k) == "string" then hasStringKey = true; filterSet[k] = val and true or false end
                        end
                        if not hasStringKey then
                            for _, name in ipairs(pickupFilter) do filterSet[tostring(name)] = true end
                        end
                    end
                    
                    local hasFilter = Solt(filterSet) ~= nil

                    local exclusionPart = nil
                    pcall(function()
                        -- Cari GroundDetail2 secara dinamis berdasarkan lokasi Generator
                        local gen = _findGenerator and _findGenerator() or nil
                        if gen and gen.Parent then
                            exclusionPart = gen.Parent:FindFirstChild("GroundDetail2")
                        end
                        -- Fallback ke Center jika tidak ketemu
                        if not exclusionPart then
                            exclusionPart = Workspace.Map.Tiles.Center.Assets.GroundDetail2
                        end
                    end)

                    for _, item in ipairs(_getAllItemsF()) do
                        if item ~= char then
                            if not (_farmBlacklist[item] and now - _farmBlacklist[item] < 10) then
                                local itemName = item.Name
                                if pickupAll or (not hasFilter) or filterSet[itemName] then
                                    local pt = _getItemPartF(item)
                                    if pt then
                                        local inSafeZone = false
                                        if genPos and (pt.Position - genPos).Magnitude < cfg.AUTO_FarmSafeZone then
                                            inSafeZone = true
                                        end
                                        if exclusionPart and exclusionPart:IsA("BasePart") then
                                            local rel = exclusionPart.CFrame:PointToObjectSpace(pt.Position)
                                            local half = exclusionPart.Size / 2
                                            if math.abs(rel.X) <= half.X + 5 and math.abs(rel.Z) <= half.Z + 5 and rel.Y >= -half.Y - 5 and rel.Y <= half.Y + 50 then
                                                inSafeZone = true
                                            end
                                        end
                                        
                                        if not inSafeZone and not _isAcrossBorder(pt.Position, lRoot.Position) then
                                            local d = (pt.Position - lRoot.Position).Magnitude
                                            if d < bestDist then bestDist = d; best = item end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    farmState.FarmItemTarget = best
                end
            end
        end

        -- Absolute Target Timeout (Mencegah maksa ambil item/zombie yang terhalang)
        local currentTarget = _farmTarget or farmState.FarmItemTarget
        if currentTarget then
            if farmState.LastAbsoluteTarget ~= currentTarget then
                farmState.LastAbsoluteTarget = currentTarget
                farmState.TargetStartTime = now
            end
            -- [FIX] Item dapat 8 detik, zombie/generator tetap 4 detik
            local absoluteTimeout = (farmState.FarmItemTarget == currentTarget) and 8 or 4
            if now - (farmState.TargetStartTime or now) > absoluteTimeout then
                _farmBlacklist[currentTarget] = now
                _farmTarget = nil
                farmState.FarmItemTarget = nil
                farmState.LastAbsoluteTarget = nil
            end
        else
            farmState.LastAbsoluteTarget = nil
        end

        -- [FIX v1.7.9] Tentukan targetPos dan isItem dari hasil scan
        local targetPos, isItem, isReturnGen
        if returnGenActive and genPos then
            targetPos = _getGeneratorStandPosition(lRoot) or genPos
            isItem = false
            isReturnGen = true
        elseif _farmTarget then
            local zRoot = _farmTarget:FindFirstChild("HumanoidRootPart")
            if zRoot then targetPos = zRoot.Position end
            isItem = false
        elseif farmState.FarmItemTarget then
            local pt = _getItemPartF(farmState.FarmItemTarget)
            if pt then targetPos = pt.Position end
            isItem = true
        end

        -- Tidak ada target: bersihkan BodyVelocity dan keluar
        if not targetPos then
            local bv = lRoot:FindFirstChild("NXFARM_BV"); if bv then bv:Destroy() end
            local bvw = lRoot:FindFirstChild("NXFARM_WALK_BV"); if bvw then bvw:Destroy() end
            local gy = lRoot:FindFirstChild("NXFARM_GY"); if gy then gy:Destroy() end
            return
        end

        -- Stuck detector
        local distToTarget = (lRoot.Position - targetPos).Magnitude
        if now - _lastFarmTime > 1.0 then
            -- [FIX] Jangan blacklist item jika karakter sudah berada di dekat item (radius 12 studs)
            -- Karakter yang sedang proses pickup tidak bergerak -> bukan berarti stuck!
            local nearItemForPickup = isItem and distToTarget < 12
            if math.abs(_lastFarmDist - distToTarget) < 1.5 and not nearItemForPickup then
                if isItem and farmState.FarmItemTarget then
                    _farmBlacklist[farmState.FarmItemTarget] = now
                    farmState.FarmItemTarget = nil
                elseif _farmTarget then
                    _farmBlacklist[_farmTarget] = now
                    _farmTarget = nil
                end
                _lastTargetScan = 0
            end
            _lastFarmTime = now; _lastFarmDist = distToTarget
        end

        -- [FIX] Untuk item: arahkan langsung ke posisi item, bukan ke atas item.
        -- hoverH hanya untuk zombie. Item dan return generator memakai posisi target langsung.
        local hoverPos
        if isItem or isReturnGen then
            -- Arahkan ke posisi item itu sendiri (tidak ada offset Y)
            hoverPos = targetPos
        else
            hoverPos = targetPos + Vector3.new(0, hoverH, 0)
        end
        local horizDist = (Vector3.new(lRoot.Position.X,0,lRoot.Position.Z) - Vector3.new(targetPos.X,0,targetPos.Z)).Magnitude

        -- Mode Overide: Jika user menekan WASD (bergerak manual)
        if lHum.MoveDirection.Magnitude > 0 then
            local bv = lRoot:FindFirstChild("NXFARM_BV"); if bv then bv:Destroy() end
            local gy = lRoot:FindFirstChild("NXFARM_GY"); if gy then gy:Destroy() end
            local bvw = lRoot:FindFirstChild("NXFARM_WALK_BV"); if bvw then bvw:Destroy() end
            -- Biarkan user mengontrol karakternya sebentar
            _lastFarmTime = tick() -- Mencegah false stuck-detection
            return 
        end

        if isReturnGen then
            _farmTarget = nil
            farmState.FarmItemTarget = nil

            local bv = lRoot:FindFirstChild("NXFARM_BV"); if bv then bv:Destroy() end
            local gy = lRoot:FindFirstChild("NXFARM_GY"); if gy then gy:Destroy() end
            local bvw = lRoot:FindFirstChild("NXFARM_WALK_BV"); if bvw then bvw:Destroy() end
            lHum.WalkSpeed = 16

            if distToTarget <= 6 then
                lHum:MoveTo(targetPos)
                _waitAtGeneratorThenResume(lRoot)
                return
            end

            if now - _lastPathCalc > 0.75 or (_pathTargetPos - targetPos).Magnitude > 5 then
                _lastPathCalc = now
                _pathTargetPos = targetPos
                task.spawn(function()
                    local ok = pcall(function() AIPATH_F:ComputeAsync(lRoot.Position, targetPos) end)
                    if ok and AIPATH_F.Status == Enum.PathStatus.Success then
                        _pathWaypoints = AIPATH_F:GetWaypoints()
                        _pathIndex = 2
                    else
                        _pathWaypoints = {}
                    end
                end)
            end

            if #_pathWaypoints > 0 and _pathIndex <= #_pathWaypoints then
                local wp = _pathWaypoints[_pathIndex]
                if wp.Action == Enum.PathWaypointAction.Jump then lHum.Jump = true end
                lHum:MoveTo(wp.Position)
                local dWp = (Vector3.new(lRoot.Position.X,0,lRoot.Position.Z) - Vector3.new(wp.Position.X,0,wp.Position.Z)).Magnitude
                if dWp < 4 then _pathIndex = _pathIndex + 1 end
            else
                if targetPos.Y - lRoot.Position.Y > 2 then lHum.Jump = true end
                lHum:MoveTo(targetPos)
                if now - (farmState.ReturnGenNotifyAt or 0) > 3 then
                    farmState.ReturnGenNotifyAt = now
                    farmState.ReturnGenArrivedAt = nil
                    Library:Notify({ Title = "Auto Return Gen", Description = "Walking to GeneratorModel...", Time = 1.5 })
                end
            end
            return
        end

        if horizDist > 15 then
            -- Pathfinding jalan kaki
            local bv = lRoot:FindFirstChild("NXFARM_BV"); if bv then bv:Destroy() end
            local gy = lRoot:FindFirstChild("NXFARM_GY"); if gy then gy:Destroy() end
            -- Server anti-cheat will rollback if WalkSpeed property is too high. 
            -- Instead, we leave it at 16 and manually push the CFrame forward.
            lHum.WalkSpeed = 16 
            local targetWalkSpeed = math.clamp(16 + (10 * farmSpeed), 16, 33)
            local extraSpeed = targetWalkSpeed - 16
            if now - _lastPathCalc > 0.5 or (_pathTargetPos - targetPos).Magnitude > 5 then
                _lastPathCalc = now; _pathTargetPos = targetPos
                task.spawn(function()
                    local ok = pcall(function() AIPATH_F:ComputeAsync(lRoot.Position, targetPos) end)
                    if ok and AIPATH_F.Status == Enum.PathStatus.Success then
                        _pathWaypoints = AIPATH_F:GetWaypoints(); _pathIndex = 2
                    else
                        _pathWaypoints = {}
                        if _farmTarget then _farmBlacklist[_farmTarget] = tick() end
                    end
                end)
            end
            if #_pathWaypoints > 0 and _pathIndex <= #_pathWaypoints then
                local wp = _pathWaypoints[_pathIndex]
                if wp.Action == Enum.PathWaypointAction.Jump then lHum.Jump = true end
                lHum:MoveTo(wp.Position)

                -- BodyVelocity speed boost for pathfinding
                if extraSpeed > 0 then
                    local bv = lRoot:FindFirstChild("NXFARM_WALK_BV")
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "NXFARM_WALK_BV"
                        bv.MaxForce = Vector3.new(100000, 0, 100000)
                        bv.Parent = lRoot
                    end
                    local dir = (Vector3.new(wp.Position.X, 0, wp.Position.Z) - Vector3.new(lRoot.Position.X, 0, lRoot.Position.Z))
                    if dir.Magnitude > 0.1 then
                        bv.Velocity = dir.Unit * targetWalkSpeed
                    else
                        bv.Velocity = Vector3.zero
                    end
                else
                    if lRoot:FindFirstChild("NXFARM_WALK_BV") then lRoot.NXFARM_WALK_BV:Destroy() end
                end
                local dWp = (Vector3.new(lRoot.Position.X,0,lRoot.Position.Z) - Vector3.new(wp.Position.X,0,wp.Position.Z)).Magnitude
                if dWp < 4 then _pathIndex = _pathIndex + 1 end
            end
        else
            -- Mode terbang / hover
            if not lRoot:FindFirstChild("NXFARM_BV") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "NXFARM_BV"; bv.MaxForce = Vector3.new(1e9,1e9,1e9); bv.Velocity = Vector3.zero; bv.Parent = lRoot
                local gy = Instance.new("BodyGyro")
                gy.Name = "NXFARM_GY"; gy.MaxTorque = Vector3.new(1e9,1e9,1e9); gy.P = 5000; gy.D = 100; gy.Parent = lRoot
            end
            local bv = lRoot:FindFirstChild("NXFARM_BV")
            local gy = lRoot:FindFirstChild("NXFARM_GY")
            if bv and gy then
                gy.CFrame = CFrame.new(lRoot.Position, targetPos)
                local dHover = (hoverPos - lRoot.Position).Magnitude
                -- [FIX] Untuk item: gunakan jarak horizontal ke item, bukan jarak 3D ke hover pos.
                -- Karakter berdiri di SAMPING item di lantai -> horizDist kecil, bukan dHover!
                local reachedTarget = isItem and (horizDist < 5) or (dHover <= 3)
                if not reachedTarget then
                    local safeFlySpeed = math.clamp(14 + (15 * farmSpeed), 14, 33)
                    bv.Velocity = (hoverPos - lRoot.Position).Unit * safeFlySpeed
                else
                    bv.Velocity = Vector3.zero
                    if isItem and farmState.FarmItemTarget then
                        local tItem = farmState.FarmItemTarget
                        farmState.PickupAttempts = farmState.PickupAttempts or {}
                        farmState.LastPickupFire = farmState.LastPickupFire or {}
                        
                        if not farmState.PickupAttempts[tItem] then
                            farmState.PickupAttempts[tItem] = tick()
                        end
                        
                        -- Tembakkan fungsi ambil secara berulang setiap 0.25 detik (Bypass server desync)
                        if tick() - (farmState.LastPickupFire[tItem] or 0) > 0.25 then
                            farmState.LastPickupFire[tItem] = tick()
                            _tryFarmPickupItem(tItem, lRoot)
                        end
                        
                        -- Beri jeda 1.5 detik untuk menunggu delay ping server sebelum menyerah
                        if not tItem.Parent or tick() - farmState.PickupAttempts[tItem] > 1.5 then
                            if tItem.Parent then
                                farmState.ConsecutivePickupFails = (farmState.ConsecutivePickupFails or 0) + 1
                                farmState.ItemFailCount = farmState.ItemFailCount or {}
                                farmState.ItemFailCount[tItem] = (farmState.ItemFailCount[tItem] or 0) + 1
                                
                                -- Jika sudah gagal 3 kali berturut-turut, blacklist item ini selama 5 menit agar tidak mondar-mandir
                                if farmState.ItemFailCount[tItem] >= 3 then
                                    _farmBlacklist[tItem] = tick() + 300
                                else
                                    _farmBlacklist[tItem] = tick()
                                end
                            else
                                farmState.ConsecutivePickupFails = 0
                            end
                            farmState.FarmItemTarget = nil
                            farmState.PickupAttempts[tItem] = nil
                            farmState.LastPickupFire[tItem] = nil
                            _lastTargetScan = 0
                        end
                    elseif returnGenActive then
                        _waitAtGeneratorThenResume(lRoot)
                    end
                end
            end
        end
    end)
end

-- Auto-start farm engine saat ada toggle yang nyala
_checkFarmToggle = function()
    local cfg = getFarmCfg()
    if cfg.AUTO_Farm or cfg.AUTO_FarmItems or cfg.AUTO_ReturnGen then
        if not farmHeartbeatConn then startAutoFarmEngine() end
    else
        stopAutoFarmEngine()
    end
end

end
_initAutoFarmEngine()

-- ============================================
-- CHARACTER RESPAWN HANDLER
-- ============================================
LocalPlayer.CharacterRemoving:Connect(function()
    if flyActive then stopFly() end
    if autoSprintActive then stopAutoSprint() end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.5)
    if Toggles.Fly and Toggles.Fly.Value then startFly() end
    if Toggles.AutoSprint and Toggles.AutoSprint.Value then startAutoSprint() end
    if Toggles.AutoPickup and Toggles.AutoPickup.Value then startAutoPickup() end
    
    if (Toggles.AutoFarmZombies and Toggles.AutoFarmZombies.Value) or (Toggles.AutoFarmItems and Toggles.AutoFarmItems.Value) then
        startAutoFarmEngine()
    end
end)

local function _initAutoFarmGem()

-- ============================================
-- AUTO FARM GEM ENGINE (Solo Mode / Generator & Power Plant)
-- ============================================
local autoFarmGemActive = false
local autoFarmGemThread = nil
local gemFarmNoclipConn = nil
local gemFarmPlayerAddedConn = nil
local gemFarmDeadStateConn = nil
local excludeFuel = {}
local cachedGeneratorLocation = nil

local function getClosestFuelPosition(currentPos)
    local foundValidFuel = nil
    while not foundValidFuel and autoFarmGemActive do
        local bestTarget = nil
        local shortestDistance = math.huge

        if droppedItemsFolder then
            for _, item in ipairs(droppedItemsFolder:GetChildren()) do
                if item.Name == "Fuel" then
                    if not excludeFuel[item] then
                        local fuelPos = item:GetPivot().Position
                        local dist = (currentPos - fuelPos).Magnitude

                        if dist < shortestDistance then
                            shortestDistance = dist
                            bestTarget = item
                        end
                    end
                end
            end
        end

        if not bestTarget then
            break
        end

        local targetPosition = bestTarget:GetPivot().Position
        local heightDifference = targetPosition.Y - currentPos.Y

        if heightDifference <= 2 then
            foundValidFuel = bestTarget
        else
            excludeFuel[bestTarget] = true
        end
    end
    return foundValidFuel
end

local function getGeneratorPosition()
    if cachedGeneratorLocation then return cachedGeneratorLocation end
    local mapFolder = Workspace:FindFirstChild("Map")
    if mapFolder then
        local tiles = mapFolder:FindFirstChild("Tiles")
        if tiles then
            for _, child in ipairs(tiles:GetChildren()) do
                if child.Name == "Generator" or child:FindFirstChild("Generator") then
                    cachedGeneratorLocation = child:GetPivot().Position
                    return cachedGeneratorLocation
                end
            end
        end
    end
    local fallbackGen = Workspace:FindFirstChild("Generator", true)
    if fallbackGen then
        cachedGeneratorLocation = fallbackGen:GetPivot().Position
        return cachedGeneratorLocation
    end
    return nil
end

local function FuelTeleport(hrp, targetFuel)
    local generatorLoc = getGeneratorPosition()
    if not hrp or not targetFuel or not generatorLoc then return end

    local fuelUnion = targetFuel:FindFirstChild("Union") or targetFuel.PrimaryPart
    local itemDrag = targetFuel:FindFirstChild("ItemDrag")
    local networkRemote = itemDrag and itemDrag:FindFirstChild("RequestNetworkOwnership")

    if fuelUnion and networkRemote then
        pcall(function()
            networkRemote:FireServer(fuelUnion)
        end)
        task.wait(0.12) 
        pcall(function()
            targetFuel:PivotTo(CFrame.new(generatorLoc) + Vector3.new(0, 1, 0))
        end)
        task.wait(0.15) 
    end
end

local function adaptiveCrawlTo(targetPos, humanoidRootPart, char)
    local finalTarget = targetPos + Vector3.new(0, 3, 0)
    local FAST_SPEED = 45          
    local SLOW_SPEED = 10          
    local STEP_DISTANCE = 0.25 
    local CLEARANCE_COOLDOWN = 0.5 
    local lastWallDetectedTime = 0
    local lockedYHeight = humanoidRootPart.Position.Y

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char} 

    while autoFarmGemActive do
        if not humanoidRootPart or not humanoidRootPart.Parent then break end
        local currentPos = humanoidRootPart.Position
        local flatTarget = Vector3.new(finalTarget.X, lockedYHeight, finalTarget.Z)
        local remainingVector = flatTarget - currentPos
        local totalDistance = remainingVector.Magnitude

        if totalDistance <= 2 or totalDistance <= STEP_DISTANCE then
            humanoidRootPart.CFrame = CFrame.new(finalTarget)
            humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, -5, 0) 
            humanoidRootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

            humanoidRootPart.Anchored = true
            task.wait(0.05)
            humanoidRootPart.Anchored = false 
            break
        end

        local direction = remainingVector.Unit
        local lookAheadDistance = 5
        local rayResult = workspace:Raycast(currentPos, direction * lookAheadDistance, raycastParams)

        if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then
            lastWallDetectedTime = os.clock()
        end

        local activeStepDistance = 0.25 
        local currentAllowedSpeed = SLOW_SPEED

        if os.clock() - lastWallDetectedTime >= CLEARANCE_COOLDOWN then
            activeStepDistance = 1.65  
            currentAllowedSpeed = FAST_SPEED
        end

        local delayInterval = activeStepDistance / currentAllowedSpeed
        local SoltPosition = currentPos + (direction * activeStepDistance)
        local flattenedPosition = Vector3.new(SoltPosition.X, lockedYHeight, SoltPosition.Z)

        humanoidRootPart.CFrame = CFrame.new(flattenedPosition)
        task.wait(delayInterval)
    end
end

stopAutoFarmGem = function()
    autoFarmGemActive = false
    if autoFarmGemThread then
        autoFarmGemThread = nil
    end
    if gemFarmNoclipConn then
        gemFarmNoclipConn:Disconnect()
        gemFarmNoclipConn = nil
    end
    if gemFarmPlayerAddedConn then
        gemFarmPlayerAddedConn:Disconnect()
        gemFarmPlayerAddedConn = nil
    end
    if gemFarmDeadStateConn then
        gemFarmDeadStateConn = nil
    end
end

startAutoFarmGem = function()
    stopAutoFarmGem()
    autoFarmGemActive = true
    excludeFuel = {}
    cachedGeneratorLocation = nil

    -- Start permanent noclip thread
    gemFarmNoclipConn = RunService.Stepped:Connect(function()
        if not autoFarmGemActive then
            if gemFarmNoclipConn then gemFarmNoclipConn:Disconnect() end
            return
        end
        local char = LocalPlayer.Character
        if char then
            for _, child in ipairs(char:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end)

    -- Hook player added for Solo Server Protection
    if not gemFarmPlayerAddedConn then
        gemFarmPlayerAddedConn = Players.PlayerAdded:Connect(function(newPlayer)
            if autoFarmGemActive and Toggles.GemFarmSoloProtection and Toggles.GemFarmSoloProtection.Value then
                if newPlayer ~= LocalPlayer then
                    warn("[CRITICAL EVACUATION]: Player joined mid-game!")
                    local PlayAgainRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):FindFirstChild("VotePlayAgain")
                    if PlayAgainRemote and PlayAgainRemote:IsA("RemoteEvent") then
                        pcall(function() PlayAgainRemote:FireServer() end)
                        task.wait(1.0)
                    end
                    LocalPlayer:Kick("[SolanaHub] Evacuation: Player joined.")
                end
            end
        end)
    end

    -- Hook dead state for auto resetting run
    if not gemFarmDeadStateConn then
        gemFarmDeadStateConn = task.spawn(function()
            while autoFarmGemActive do
                task.wait(1)
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    local PlayAgainRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):FindFirstChild("VotePlayAgain")
                    if PlayAgainRemote and PlayAgainRemote:IsA("RemoteEvent") then
                        pcall(function() PlayAgainRemote:FireServer() end)
                    end
                    task.wait(5)
                end
            end
        end)
    end

    autoFarmGemThread = task.spawn(function()
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end
        task.wait(1.5)

        local PlayAgainRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc"):FindFirstChild("VotePlayAgain")
        
        -- Evacuate Check (Solo Mode)
        local function checkEvacuation()
            if Toggles.GemFarmSoloProtection and Toggles.GemFarmSoloProtection.Value then
                if #Players:GetPlayers() > 1 then
                    warn("[CRITICAL EVACUATION]: Other player detected in server!")
                    if PlayAgainRemote and PlayAgainRemote:IsA("RemoteEvent") then
                        pcall(function() PlayAgainRemote:FireServer() end)
                        task.wait(1.0)
                    end
                    LocalPlayer:Kick("[SolanaHub] Evacuation: Players detected.")
                end
            end
        end

        checkEvacuation()

        local char = LocalPlayer.Character
        local hrp = char and char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then stopAutoFarmGem(); return end

        -- 60-second safety timeout
        task.delay(60.0, function()
            if autoFarmGemActive then
                warn("[SolanaHub] Auto Farm Gem Timeout. Voting Play Again.")
                if PlayAgainRemote and PlayAgainRemote:IsA("RemoteEvent") then
                    pcall(function() PlayAgainRemote:FireServer() end)
                end
            end
        end)

        -- Step 1: First fuel
        checkEvacuation()
        local fuelOne = getClosestFuelPosition(hrp.Position)
        if fuelOne and autoFarmGemActive then
            adaptiveCrawlTo(fuelOne:GetPivot().Position, hrp, char)
            task.wait(0.3)
            FuelTeleport(hrp, fuelOne)
            task.wait(0.5)
        end

        -- Step 2: Second fuel
        checkEvacuation()
        local fuelTwo = getClosestFuelPosition(hrp.Position)
        if fuelTwo and autoFarmGemActive then
            adaptiveCrawlTo(fuelTwo:GetPivot().Position, hrp, char)
            task.wait(0.3)
            FuelTeleport(hrp, fuelTwo)
            task.wait(0.5)
        end

        -- Step 3: Power Plant interaction
        checkEvacuation()
        local mapFolder = Workspace:FindFirstChild("Map")
        local powerBoxData = {}
        local interactionSuccess = false

        if mapFolder and mapFolder:FindFirstChild("Tiles") then
            for _, child in ipairs(mapFolder.Tiles:GetChildren()) do
                if child.Name == "Power Plant" then
                    local powerBox = child:FindFirstChild("Power Box")
                    if powerBox and powerBox:IsA("Model") then
                        table.insert(powerBoxData, {
                            Instance = powerBox,
                            Position = powerBox:GetPivot().Position
                        })
                    end
                end
            end
        end

        if #powerBoxData > 0 and autoFarmGemActive then
            table.sort(powerBoxData, function(a, b)
                return (hrp.Position - a.Position).Magnitude < (hrp.Position - b.Position).Magnitude
            end)

            local chosenBox = powerBoxData[1].Instance
            local finalBoxTarget = powerBoxData[1].Position

            adaptiveCrawlTo(finalBoxTarget, hrp, char)
            task.wait(0.5)

            if (hrp.Position - finalBoxTarget).Magnitude < 15 and autoFarmGemActive then
                local prompt = chosenBox:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    for i = 1, 3 do
                        if not autoFarmGemActive then break end
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        else
                            prompt:InputHoldBegin()
                            task.wait(prompt.HoldDuration + 0.05)
                            prompt:InputHoldEnd()
                        end
                        task.wait(0.1)
                    end
                    interactionSuccess = true
                end
            end
        end

        -- Reset / Play Again
        checkEvacuation()
        if interactionSuccess and autoFarmGemActive then
            if PlayAgainRemote and PlayAgainRemote:IsA("RemoteEvent") then
                pcall(function() PlayAgainRemote:FireServer() end)
                Library:Notify({ Title = "Auto Farm Gem", Description = "Completed! Executed Vote Play Again.", Time = 3 })
            end
        end
    end)
end
end
_initAutoFarmGem()

-- ============================================
-- MASSIVE FEATURE UPDATE
-- ============================================

local _isProtectedTrashName

getgenv().STA_E = {}

local function _initMassiveUtilities()

-- CTRL+CLICK TELEPORT
STA_E.ctrlClickConn = nil
STA_E.stopCtrlClickTP = function()
    if STA_E.ctrlClickConn then STA_E.ctrlClickConn:Disconnect(); STA_E.ctrlClickConn = nil end
end
STA_E.startCtrlClickTP = function()
    STA_E.stopCtrlClickTP()
    local mouse = LocalPlayer:GetMouse()
    STA_E.ctrlClickConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                if Toggles.CtrlClickTP and Toggles.CtrlClickTP.Value then
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and mouse.Target then
                        hrp.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
    end)
end

-- ANTI RAGDOLL & ANTI KNOCKBACK
STA_E.antiKnockbackConn = nil
STA_E.antiRagdollDescConn = nil
STA_E.antiRagdollStateConn = nil
STA_E.antiRagdollCharAddedConn = nil

STA_E.stopAntiRagdoll = function()
    if STA_E.antiKnockbackConn then STA_E.antiKnockbackConn:Disconnect(); STA_E.antiKnockbackConn = nil end
    if STA_E.antiRagdollDescConn then STA_E.antiRagdollDescConn:Disconnect(); STA_E.antiRagdollDescConn = nil end
    if STA_E.antiRagdollStateConn then STA_E.antiRagdollStateConn:Disconnect(); STA_E.antiRagdollStateConn = nil end
    if STA_E.antiRagdollCharAddedConn then STA_E.antiRagdollCharAddedConn:Disconnect(); STA_E.antiRagdollCharAddedConn = nil end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetAttribute("KnockbackImmune", nil)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
        end)
    end
    if char then
        pcall(function()
            char:SetAttribute("KnockbackResistance", nil)
        end)
    end
end

STA_E.startAntiRagdoll = function()
    STA_E.stopAntiRagdoll()
    
    local function isHarmfulForce(child)
        if not child then return false end
        if child:IsA("BodyGyro") or child.Name == "BodyGyro" or child.Name == "AimRotate" then
            return false -- NEVER destroy game aiming gyro
        end
        if string.find(child.Name, "NXFARM") then
            return false -- Preserve our own auto-farm movers
        end
        if child:FindFirstAncestorWhichIsA("VehicleSeat") or child:FindFirstAncestorWhichIsA("Seat") then
            return false -- NEVER destroy vehicle physics
        end
        if child.Name == "KnockbackForce" or 
           child:IsA("BodyVelocity") or 
           child:IsA("LinearVelocity") or 
           child:IsA("VectorForce") or 
           child:IsA("BodyForce") or 
           child:IsA("BodyThrust") then
            return true
        end
        return false
    end
    
    local function setupChar(char)
        if not char then return end
        local hum = char:WaitForChild("Humanoid", 3) or char:FindFirstChildOfClass("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart", 3) or char:FindFirstChild("HumanoidRootPart")
        
        if hum then
            pcall(function()
                hum:SetAttribute("KnockbackImmune", true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                if not hum.SeatPart and not char:GetAttribute("InVehicle") then
                    hum.PlatformStand = false
                end
            end)
            
            if STA_E.antiRagdollStateConn then STA_E.antiRagdollStateConn:Disconnect() end
            STA_E.antiRagdollStateConn = hum.StateChanged:Connect(function(oldState, newState)
                if not Toggles.AntiRagdoll or not Toggles.AntiRagdoll.Value then return end
                local inVehicle = (hum.SeatPart ~= nil) or (char:GetAttribute("InVehicle") == true)
                if not inVehicle then
                    if newState == Enum.HumanoidStateType.Ragdoll or 
                       newState == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                        hum.PlatformStand = false
                    end
                end
            end)
        end
        
        if char then
            pcall(function()
                char:SetAttribute("KnockbackResistance", 1)
            end)
            
            if STA_E.antiRagdollDescConn then STA_E.antiRagdollDescConn:Disconnect() end
            STA_E.antiRagdollDescConn = char.DescendantAdded:Connect(function(child)
                if not Toggles.AntiRagdoll or not Toggles.AntiRagdoll.Value then return end
                if isHarmfulForce(child) then
                    task.defer(function()
                        if child and child.Parent then child:Destroy() end
                    end)
                end
            end)
            
            -- Clean any existing forces in character parts without touching BodyGyro or Vehicles
            for _, child in ipairs(char:GetDescendants()) do
                if isHarmfulForce(child) then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
    
    setupChar(LocalPlayer.Character)
    
    STA_E.antiRagdollCharAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        if Toggles.AntiRagdoll and Toggles.AntiRagdoll.Value then
            setupChar(newChar)
        end
    end)
    
    STA_E.antiKnockbackConn = RunService.Stepped:Connect(function()
        if not Toggles.AntiRagdoll or not Toggles.AntiRagdoll.Value then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        local inVehicle = (hum and hum.SeatPart ~= nil) or (char and char:GetAttribute("InVehicle") == true)
        
        if hum then
            if hum:GetAttribute("KnockbackImmune") ~= true then
                hum:SetAttribute("KnockbackImmune", true)
            end
            if not inVehicle and hum.PlatformStand then
                hum.PlatformStand = false
            end
        end
        if char then
            if char:GetAttribute("KnockbackResistance") ~= 1 then
                char:SetAttribute("KnockbackResistance", 1)
            end
        end
        
        -- Prevent physical collision push from large zombie models (Brute/Muscle/etc)
        local charsFolder = workspace:FindFirstChild("Characters")
        if charsFolder then
            for _, mob in ipairs(charsFolder:GetChildren()) do
                if mob ~= char and (mob:GetAttribute("Zombie") or mob:FindFirstChild("MobAI")) then
                    for _, part in ipairs(mob:GetChildren()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
        
        -- Only clamp character velocity when NOT in a vehicle so vehicles drive at full speed
        if hrp and not inVehicle then
            local maxAllowed = hum and math.max(hum.WalkSpeed + 8, 25) or 25
            local hrpVel = hrp.AssemblyLinearVelocity
            local horizVel = Vector3.new(hrpVel.X, 0, hrpVel.Z)
            
            -- Clamp vertical slam & cancel abnormal horizontal flings
            local clampedY = math.clamp(hrpVel.Y, -35, 52)
            if horizVel.Magnitude > maxAllowed or hrpVel.Y > 52 or hrpVel.Y < -35 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, clampedY, 0)
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

-- BOSS / BRUTE ALERT
STA_E.bossAlertConn = nil
STA_E.alertedBosses = {}
STA_E.stopBossAlert = function()
    if STA_E.bossAlertConn then STA_E.bossAlertConn:Disconnect(); STA_E.bossAlertConn = nil end
    STA_E.alertedBosses = {}
end
STA_E.startBossAlert = function()
    STA_E.stopBossAlert()
    if not charactersFolder then return end

    local function checkBoss(z)
        if not Toggles.BossAlert or not Toggles.BossAlert.Value then return end
        if z.Name == "Boss" or z.Name == "Brute" then
            if not STA_E.alertedBosses[z] then
                STA_E.alertedBosses[z] = true
                Library:Notify({ Title = "DANGER", Description = z.Name .. " has spawned!", Time = 5 })
            end
        end
    end

    -- Pindai anak objek yang sudah ada saat ini
    for _, z in ipairs(charactersFolder:GetChildren()) do
        checkBoss(z)
    end

    -- Hubungkan listener untuk menangkap boss baru yang spawn
    STA_E.bossAlertConn = charactersFolder.ChildAdded:Connect(checkBoss)
end

-- AUTO REVIVE TEAMMATE
STA_E.autoReviveConn = nil
STA_E.stopAutoRevive = function()
    if STA_E.autoReviveConn then STA_E.autoReviveConn:Disconnect(); STA_E.autoReviveConn = nil end
end
STA_E.startAutoRevive = function()
    STA_E.stopAutoRevive()
    local lastCheck = 0
    STA_E.autoReviveConn = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoRevive or not Toggles.AutoRevive.Value then return end
        local now = tick()
        if now - lastCheck < 0.25 then return end
        lastCheck = now

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local radius = Options.ReviveRadius and Options.ReviveRadius.Value or 15
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local pHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if pHrp then
                    local dist = (hrp.Position - pHrp.Position).Magnitude
                    if dist <= radius then
                        local prompt = pHrp:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and (prompt.Name == "Revive" or prompt.ActionText == "Revive") then
                            if fireproximityprompt then fireproximityprompt(prompt) end
                        end
                    end
                end
            end
        end
    end)
end

-- AUTO SUPPRESSOR
STA_E.autoSuppressorConn = nil
STA_E.stopAutoSuppressor = function()
    if STA_E.autoSuppressorConn then STA_E.autoSuppressorConn:Disconnect(); STA_E.autoSuppressorConn = nil end
end
STA_E.startAutoSuppressor = function()
    STA_E.stopAutoSuppressor()
    local lastFire = 0
    STA_E.autoSuppressorConn = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoSuppressor or not Toggles.AutoSuppressor.Value then return end
        local now = tick()
        if now - lastFire < 2.0 then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        
        if tool:FindFirstChild("Ammo") or tool:FindFirstChild("Clip") then
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp and bp:FindFirstChild("Suppressor") then
                lastFire = now
                pcall(function()
                    local r = ReplicatedStorage:FindFirstChild("Remotes")
                    local addSup = r and r:FindFirstChild("Tools") and r.Tools:FindFirstChild("AddSuppressor")
                    if addSup then addSup:FireServer(tool) end
                end)
            end
        end
    end)
end

-- INFINITE AMMO (NO RELOAD)
STA_E.infiniteAmmoConn = nil
STA_E.stopInfiniteAmmo = function()
    if STA_E.infiniteAmmoConn then STA_E.infiniteAmmoConn:Disconnect(); STA_E.infiniteAmmoConn = nil end
end
STA_E.startInfiniteAmmo = function()
    STA_E.stopInfiniteAmmo()
    STA_E.infiniteAmmoConn = RunService.Heartbeat:Connect(function()
        if not Toggles.InfiniteAmmo or not Toggles.InfiniteAmmo.Value then return end
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local clip = tool:FindFirstChild("Clip") or tool:FindFirstChild("Ammo")
            local maxClip = tool:FindFirstChild("MaxClip") or tool:FindFirstChild("MaxAmmo")
            if clip and maxClip and clip:IsA("IntValue") and maxClip:IsA("IntValue") then
                if clip.Value < maxClip.Value then
                    clip.Value = maxClip.Value
                end
            end
        end
    end)
end

-- ANTI PROXIMITY PROMPT (hold -> click once)
STA_E.antiPromptConn = nil
STA_E._antiPromptOriginalHold = STA_E._antiPromptOriginalHold or setmetatable({}, { __mode = "k" })

local function _applyNoHoldPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    if STA_E._antiPromptOriginalHold[prompt] == nil then
        STA_E._antiPromptOriginalHold[prompt] = prompt.HoldDuration
    end
    if prompt.HoldDuration ~= 0 then
        prompt.HoldDuration = 0
    end
end

STA_E.stopAntiProximityPrompt = function()
    if STA_E.antiPromptConn then STA_E.antiPromptConn:Disconnect(); STA_E.antiPromptConn = nil end
    for prompt, originalHold in pairs(STA_E._antiPromptOriginalHold) do
        pcall(function()
            if prompt and prompt.Parent then
                prompt.HoldDuration = originalHold
            end
        end)
    end
    STA_E._antiPromptOriginalHold = setmetatable({}, { __mode = "k" })
end

STA_E.startAntiProximityPrompt = function()
    STA_E.stopAntiProximityPrompt()

    -- Terapkan langsung ke prompt yang ada di folder Map dan Structures (lebih spesifik dibanding scan seluruh Workspace)
    local scanFolders = {}
    local map = Workspace:FindFirstChild("Map")
    local struct = Workspace:FindFirstChild("Structures")
    if map then table.insert(scanFolders, map) end
    if struct then table.insert(scanFolders, struct) end

    for _, folder in ipairs(scanFolders) do
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                _applyNoHoldPrompt(obj)
            end
        end
    end

    -- Hubungkan ke ProximityPromptService.PromptShown untuk menangani prompt baru secara efisien tanpa loop
    local ProximityPromptService = game:GetService("ProximityPromptService")
    STA_E.antiPromptConn = ProximityPromptService.PromptShown:Connect(function(prompt)
        _applyNoHoldPrompt(prompt)
    end)
end

-- ============================================
-- AUTO OPEN CHEST / CONTAINER (Aura)
-- ============================================
STA_E.autoOpenChestRunning = false
STA_E.autoOpenChestConn = nil
STA_E._openedPromptCooldown = setmetatable({}, { __mode = "k" })

local function _isPromptBlacklisted(prompt)
    if not prompt or not prompt.Parent then return true end

    -- Check if descendant of workspace.Crafting or workspace.Crafting.Workbench
    local craftingFolder = Workspace:FindFirstChild("Crafting")
    if craftingFolder and prompt:IsDescendantOf(craftingFolder) then
        return true
    end

    -- Check ancestors
    if prompt:FindFirstAncestor("Crafting") or prompt:FindFirstAncestor("Workbench") then
        return true
    end

    -- Check parent/model names
    local pName = string.lower(prompt.Parent.Name)
    if string.find(pName, "workbench") or string.find(pName, "crafting") then
        return true
    end

    -- Check prompt ActionText or ObjectText
    local action = string.lower(tostring(prompt.ActionText or ""))
    local object = string.lower(tostring(prompt.ObjectText or ""))
    if string.find(action, "craft") or string.find(object, "workbench") or string.find(object, "craft") then
        return true
    end

    return false
end

local function _tryAutoOpenPrompt(prompt, playerPos, maxDist)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
    local parent = prompt.Parent
    if not parent then return false end

    -- Ignore Workbench & Crafting
    if _isPromptBlacklisted(prompt) then
        return false
    end

    local now = os.clock()
    if STA_E._openedPromptCooldown[prompt] and (now - STA_E._openedPromptCooldown[prompt]) < 0.6 then
        return false
    end

    local promptPos
    if parent:IsA("BasePart") then
        promptPos = parent.Position
    elseif parent:IsA("Model") then
        local prim = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart", true)
        promptPos = prim and prim.Position or parent:GetPivot().Position
    end
    if not promptPos then return false end

    local allowedDist = maxDist or (Options.AutoOpenChestRadius and Options.AutoOpenChestRadius.Value) or 20
    local dist = (promptPos - playerPos).Magnitude
    if dist <= allowedDist then
        STA_E._openedPromptCooldown[prompt] = now
        pcall(function()
            prompt.RequiresLineOfSight = false
            prompt.HoldDuration = 0
            if fireproximityprompt then
                fireproximityprompt(prompt)
            else
                prompt:InputHoldBegin()
                task.wait(0.02)
                prompt:InputHoldEnd()
            end
        end)
        return true
    end
    return false
end

STA_E.stopAutoOpenChest = function()
    STA_E.autoOpenChestRunning = false
    if STA_E.autoOpenChestConn then
        STA_E.autoOpenChestConn:Disconnect()
        STA_E.autoOpenChestConn = nil
    end
    STA_E._openedPromptCooldown = setmetatable({}, { __mode = "k" })
end

STA_E.startAutoOpenChest = function()
    STA_E.stopAutoOpenChest()
    STA_E.autoOpenChestRunning = true

    local ProximityPromptService = game:GetService("ProximityPromptService")

    -- 1. Event-driven: Instant trigger when prompt is shown on client
    STA_E.autoOpenChestConn = ProximityPromptService.PromptShown:Connect(function(prompt)
        if not STA_E.autoOpenChestRunning then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            _tryAutoOpenPrompt(prompt, hrp.Position)
        end
    end)

    -- 2. Lightweight radius scanner (3 times per second): Scans chests & structures in range
    task.spawn(function()
        while STA_E.autoOpenChestRunning do
            task.wait(0.3)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local playerPos = hrp.Position
                local radius = (Options.AutoOpenChestRadius and Options.AutoOpenChestRadius.Value) or 20

                local scanFolders = {}
                local map = Workspace:FindFirstChild("Map")
                local crates = map and map:FindFirstChild("Crates")
                local struct = Workspace:FindFirstChild("Structures")

                if crates then table.insert(scanFolders, crates) end
                if struct then table.insert(scanFolders, struct) end
                if map then table.insert(scanFolders, map) end

                for _, folder in ipairs(scanFolders) do
                    if not STA_E.autoOpenChestRunning then break end
                    for _, prompt in ipairs(folder:GetDescendants()) do
                        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                            _tryAutoOpenPrompt(prompt, playerPos, radius)
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- HITBOX EXPANDER (loop aktif)
-- ============================================
-- [OPT] Hitbox: task.spawn + task.wait(0.1) = 10fps, jauh lebih ringan dari 60fps Heartbeat
STA_E._hitboxRunning  = false
STA_E.hitboxOriginals = {}
STA_E.stopHitbox = function()
    STA_E._hitboxRunning = false
    for part, sz in pairs(STA_E.hitboxOriginals) do
        pcall(function() if part and part.Parent then part.Size = sz end end)
    end
    STA_E.hitboxOriginals = {}
end
STA_E.startHitbox = function()
    STA_E.stopHitbox()
    STA_E._hitboxRunning = true
    task.spawn(function()
        while STA_E._hitboxRunning do
            if Toggles.HitboxEnabled and Toggles.HitboxEnabled.Value then
                local sz = Options.HitboxSize and tonumber(Options.HitboxSize.Value) or 10

                -- Kumpulkan karakter player agar tidak ikut di-expand
                local playerCharSet = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character then playerCharSet[p.Character] = true end
                end

                -- Cari semua model di Workspace yang punya Humanoid (= zombie/mob)
                -- Bisa dari folder Characters, Mobs, Enemies, dll â€“ apapun namanya
                local function scanForMobs(parent)
                    for _, obj in ipairs(parent:GetChildren()) do
                        if obj:IsA("Model") and not playerCharSet[obj] then
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if hum then
                                -- ini mob/zombie, expand semua BasePart-nya
                                for _, part in ipairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        if not STA_E.hitboxOriginals[part] then
                                            STA_E.hitboxOriginals[part] = part.Size
                                        end
                                        pcall(function()
                                            part.Locked = false
                                            part.Size   = Vector3.new(sz, sz, sz)
                                        end)
                                    end
                                end
                            end
                        elseif obj:IsA("Folder") or obj:IsA("Model") then
                            scanForMobs(obj)
                        end
                    end
                end

                scanForMobs(Workspace)
            end
            task.wait(0.1)
        end
    end)
end

-- ============================================
-- SPINBOT / ANTI-AIM (loop aktif)
-- [OPT] Throttle ke 30fps (0.033s)  - Â visual cukup smooth tanpa 60fps penuh
-- ============================================
STA_E._spinbotRunning = false
STA_E.stopSpinbot = function()
    STA_E._spinbotRunning = false
end
STA_E.startSpinbot = function()
    STA_E.stopSpinbot()
    STA_E._spinbotRunning = true
    task.spawn(function()
        while STA_E._spinbotRunning do
            if Toggles.SpinbotEnabled and Toggles.SpinbotEnabled.Value then
                local char = LocalPlayer.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    pcall(function() hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(30), 0) end)
                end
            end
            task.wait(0.033)  -- [OPT] 30fps cukup untuk spin visual
        end
    end)
end

end
_initMassiveUtilities()

local function _initAutoUseAndHeal()

-- ============================================
-- AUTO USE / SMART HEAL (loop bersama)
-- ============================================
STA_E.autoUseConn    = nil
STA_E.autoUseLastFire = 0

local _AUTO_HEAL_ITEMS = {
    ["Bandage"] = true, ["Medkit"] = true,
    ["Compound H"] = true, ["Compound I"] = true, ["Compound R"] = true, ["Compound S"] = true,
}
local _AUTO_FOOD_ITEMS = {
    ["Chips"] = true, ["Carrot"] = true, ["Bloxiade"] = true,
    ["Beans"] = true, ["MRE"] = true, ["Bloxy Cola"] = true,
}
local function _isConsumableName(name)
    return _AUTO_HEAL_ITEMS[name] or _AUTO_FOOD_ITEMS[name]
end

local function _isInGeneratorZoneByHRP(hrp)
    if not hrp then return false end
    local zone = workspace:FindFirstChild("Structures")
    zone = zone and zone:FindFirstChild("Generator")
    zone = zone and zone:FindFirstChild("ZoneVisual")
    if zone and zone:IsA("BasePart") then
        local rel = zone.CFrame:PointToObjectSpace(hrp.Position)
        local half = zone.Size * 0.5
        local pad = Vector3.new(1.5, 4, 1.5)
        return
            math.abs(rel.X) <= (half.X + pad.X) and
            math.abs(rel.Y) <= (half.Y + pad.Y) and
            math.abs(rel.Z) <= (half.Z + pad.Z)
    end
    local gen = _findGenerator and _findGenerator() or nil
    local genPart = gen and (gen:IsA("BasePart") and gen or (gen:IsA("Model") and gen.PrimaryPart)) or nil
    if not genPart then return false end
    local genRadius = Options.FarmSafeZone and Options.FarmSafeZone.Value or 60
    return (hrp.Position - genPart.Position).Magnitude <= genRadius
end

local function _readHungerPercent()
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local best = nil
    for _, ui in ipairs(pg:GetDescendants()) do
        if (ui:IsA("Frame") or ui:IsA("ImageLabel")) and ui.Visible then
            local c = ui:IsA("ImageLabel") and ui.ImageColor3 or ui.BackgroundColor3
            local isOrange = c and c.R > 0.75 and c.G > 0.35 and c.G < 0.75 and c.B < 0.3
            if isOrange and ui.AbsoluteSize.X >= 80 and ui.AbsoluteSize.Y >= 8 and ui.AbsoluteSize.Y <= 40 then
                local p
                if ui.Size.X.Scale and ui.Size.X.Scale > 0 and ui.Size.X.Scale <= 1 then
                    p = ui.Size.X.Scale
                elseif ui.Parent and ui.Parent:IsA("GuiObject") and ui.Parent.AbsoluteSize.X > 0 then
                    p = ui.AbsoluteSize.X / ui.Parent.AbsoluteSize.X
                end
                if p and p >= 0 and p <= 1 then
                    if not best or p > best then best = p end
                end
            end
        end
    end
    return best and (best * 100) or nil
end

local function _consumeTool(hum, tool, now)
    STA_E.autoUseLastFire = now
    pcall(function()
        hum:EquipTool(tool)
        task.wait(0.1)
        
        local beginUse = tool:FindFirstChild("BeginUse")
        local endUse = tool:FindFirstChild("EndUse")
        
        if beginUse and beginUse:IsA("RemoteEvent") and endUse and endUse:IsA("RemoteEvent") then
            -- STA Medical/Food item logic
            beginUse:FireServer()
            task.wait(0.05)
            endUse:FireServer(true)
            return
        end

        local useRem = tool:FindFirstChild("Use")
                    or tool:FindFirstChild("Consume")
                    or tool:FindFirstChild("Eat")
                    or tool:FindFirstChild("Heal")
        if useRem and useRem:IsA("RemoteEvent") then
            useRem:FireServer()
        else
            tool:Activate()
        end
    end)
end

local function _tryEatNearbyDroppedItem(hrp, now)
    if not hrp or not droppedItemsFolder then return false end
    local radius = Options.AutoUseRadius and Options.AutoUseRadius.Value or 15
    local pickR = getPickUpRemote and getPickUpRemote() or nil
    if not pickR then return false end

    for _, item in ipairs(droppedItemsFolder:GetChildren()) do
        if item and item.Parent and _AUTO_FOOD_ITEMS[item.Name] then
            local p = item.PrimaryPart or getItemMainPart(item)
            if p and (p.Position - hrp.Position).Magnitude <= radius then
                STA_E.autoUseLastFire = now
                pcall(function() pickR:FireServer(item) end)
                pcall(function()
                    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                end)
                if firetouchinterest then
                    pcall(function() firetouchinterest(hrp, p, 0) end)
                    task.delay(0.03, function()
                        pcall(function() firetouchinterest(hrp, p, 1) end)
                    end)
                end
                return true
            end
        end
    end
    return false
end

STA_E.stopAutoUse = function()
    if STA_E.autoUseConn then STA_E.autoUseConn:Disconnect(); STA_E.autoUseConn = nil end
end
STA_E.startAutoUse = function()
    STA_E.stopAutoUse()
    STA_E.autoUseConn = RunService.Heartbeat:Connect(function()
        local doAutoUse   = Toggles.AutoUse       and Toggles.AutoUse.Value
        local doSmartHeal = Toggles.SmartAutoHeal  and Toggles.SmartAutoHeal.Value
        local doAutoEat   = Toggles.AutoEat and Toggles.AutoEat.Value
        if not doAutoUse and not doSmartHeal and not doAutoEat then return end
        local now = tick()
        if now - STA_E.autoUseLastFire < 1.5 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local filterRaw = Options.AutoUseFilter and Options.AutoUseFilter.Value or {}
        local filter = (type(filterRaw) == "table") and filterRaw or (type(filterRaw) == "string" and {[filterRaw] = true} or {})
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not bp then return end

        -- Priority 1: Smart Heal (HP rendah)
        if doSmartHeal then
            local threshold = Options.HealThreshold and Options.HealThreshold.Value or 50
            if (hum.Health / hum.MaxHealth * 100) < threshold then
                for _, tool in ipairs(bp:GetChildren()) do
                    if tool:IsA("Tool") and _AUTO_HEAL_ITEMS[tool.Name] and ((not Solt(filter)) or filter[tool.Name]) then
                        _consumeTool(hum, tool, now)
                        return
                    end
                end
            end
        end

        -- Priority 2: Auto Eat (hanya di luar zona pangkalan)
        if doAutoEat and not _isInGeneratorZoneByHRP(hrp) then
            local hNow = _readHungerPercent()
            local hThreshold = Options.HungerThreshold and Options.HungerThreshold.Value or 85
            local shouldEat = (hNow == nil) or (hNow <= hThreshold)
            if shouldEat then
                if _tryEatNearbyDroppedItem(hrp, now) then return end
                for _, tool in ipairs(bp:GetChildren()) do
                    if tool:IsA("Tool") and _AUTO_FOOD_ITEMS[tool.Name] then
                        _consumeTool(hum, tool, now)
                        return
                    end
                end
            end
        end

        -- Priority 3: Auto Use consumables only (avoid equipping weapons/hotbar tools)
        if not doAutoUse then return end
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local allowed = (not Solt(filter)) or filter[tool.Name]
                if allowed and _isConsumableName(tool.Name) then
                    _consumeTool(hum, tool, now)
                    break
                end
            end
        end
    end)
end

-- ============================================
-- AUTO TRASH (loop aktif)
-- ============================================
STA_E.autoTrashConn = nil
STA_E.stopAutoTrash = function()
    if STA_E.autoTrashConn then STA_E.autoTrashConn:Disconnect(); STA_E.autoTrashConn = nil end
end
end
_initAutoUseAndHeal()

local function _initTrashAndDrop()
local function _isToolInPlayer(tool, char, bp)
    return tool and tool.Parent and (tool.Parent == char or tool.Parent == bp)
end

local _AUTO_TRASH_PROTECTED = {
    ["Backpack"] = true,
    ["Basic Backpack"] = true,
    ["Good Backpack"] = true,
    ["Great Backpack"] = true,
}

-- Also protect all guns, melees, and armors by default
for _, name in ipairs(gunItems or {}) do _AUTO_TRASH_PROTECTED[name] = true end
for _, name in ipairs(meleeItems or {}) do _AUTO_TRASH_PROTECTED[name] = true end
for _, name in ipairs(armorItems or {}) do _AUTO_TRASH_PROTECTED[name] = true end

_isProtectedTrashName = function(name)
    if type(name) ~= "string" then return false end
    if _AUTO_TRASH_PROTECTED[name] then return true end
    local low = string.lower(name)
    if low:find("backpack") or low:find("gun") or low:find("rifle") or low:find("shotgun") or low:find("katana") or low:find("sword") then
        return true
    end
    return false
end

local function _tryDropToolFE(tool, char, bp, dropCF, noEquip)
    if not tool or not tool:IsA("Tool") then return false end
    if _isProtectedTrashName(tool.Name) then return false end
    if not _isToolInPlayer(tool, char, bp) then return true end

    -- Primary: fire backpack remote
    local adjustR = getAdjustBackpackRemote()
    if adjustR then
        pcall(function() adjustR:FireServer("Drop", tool) end)
    end
    task.wait(0.05)
    return not _isToolInPlayer(tool, char, bp)
end

local function _tryDropByNameFE(itemName, dropCF)
    if type(itemName) ~= "string" or itemName == "" then return false end
    if _isProtectedTrashName(itemName) then return false end

    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not char or not bp then return false end

    -- Find the tool in backpack or character
    local targetTool = bp:FindFirstChild(itemName) or char:FindFirstChild(itemName)
    if not targetTool or not targetTool:IsA("Tool") then return false end

    return _tryDropToolFE(targetTool, char, bp, dropCF, false)
end

local function _getBottomSlotNameSet()
    local out = {}
    local function addName(n)
        if type(n) ~= "string" or n == "" then return end
        out[n] = true
    end

    -- Equipped slot (held tool) is always considered hotbar/quick slot.
    local char = LocalPlayer and LocalPlayer.Character
    if char then
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then
                addName(obj.Name)
            end
        end
    end

    -- Read visible bottom-bar labels/buttons from PlayerGui.
    local pg = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, ui in ipairs(pg:GetDescendants()) do
            if ui:IsA("TextLabel") or ui:IsA("TextButton") then
                local txt = tostring(ui.Text or "")
                if txt ~= "" and ui.Visible and ui.AbsolutePosition.Y > (workspace.CurrentCamera.ViewportSize.Y * 0.55) then
                    addName(txt)
                end
            end
        end
    end

    return out
end

STA_E.startAutoTrash = function()
    STA_E.stopAutoTrash()
    local lastDrop = 0
    STA_E.autoTrashConn = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoTrash or not Toggles.AutoTrash.Value then return end
        local now = tick()
        if now - lastDrop < 0.5 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local filter = Options.AutoTrashFilter and Options.AutoTrashFilter.Value or {}
        -- If filter is empty, do not drop any items
        if not Solt(filter) then return end

        -- Only active if inside Generator/Base zone
        local inGeneratorZone = false
        local zone = workspace:FindFirstChild("Structures")
        zone = zone and zone:FindFirstChild("Generator")
        zone = zone and zone:FindFirstChild("ZoneVisual")
        if zone and zone:IsA("BasePart") then
            local rel = zone.CFrame:PointToObjectSpace(hrp.Position)
            local half = zone.Size * 0.5
            local pad = Vector3.new(1.5, 4, 1.5)
            inGeneratorZone =
                math.abs(rel.X) <= (half.X + pad.X) and
                math.abs(rel.Y) <= (half.Y + pad.Y) and
                math.abs(rel.Z) <= (half.Z + pad.Z)
        else
            local gen = _findGenerator and _findGenerator() or nil
            local genPart = gen and (gen:IsA("BasePart") and gen or (gen:IsA("Model") and gen.PrimaryPart)) or nil
            if not genPart then return end
            local genRadius = Options.FarmSafeZone and Options.FarmSafeZone.Value or 60
            inGeneratorZone = (hrp.Position - genPart.Position).Magnitude <= genRadius
        end
        if not inGeneratorZone then return end

        local dropCF = hrp.CFrame
        local slotNames = _getBottomSlotNameSet()

        -- Only drop items explicitly enabled in AutoTrashFilter
        for itemName, enabled in pairs(filter) do
            if enabled and not _isProtectedTrashName(itemName) and not slotNames[itemName] then
                lastDrop = now
                _tryDropByNameFE(itemName, dropCF)
                return
            end
        end
    end)
end

end
_initTrashAndDrop()

local loadClassAvatarsFromFile, saveClassAvatarsToFile
local scanLobbyClassAvatars
local STA_ClassAvatars

local function _initClassAvatarCloner()

applyESPTextSize = function(size)
    espConfig.textSize = size
    local small = math.max(size - 2, 8)
    for _, sys in pairs(espSystems) do
        for _, esp in pairs(sys.instances) do
            if esp.NameLabel then esp.NameLabel.TextSize = size end
            if esp.DistLabel  then esp.DistLabel.TextSize  = small end
        end
    end
    for _, esp in pairs(mobESPInstances) do
        if esp.NameLabel then esp.NameLabel.TextSize = size end
        if esp.DistLabel  then esp.DistLabel.TextSize  = small end
    end
    for _, esp in pairs(structureESPInstances) do
        if esp.NameLabel then esp.NameLabel.TextSize = size end
        if esp.DistLabel  then esp.DistLabel.TextSize  = small end
    end
    for _, esp in pairs(playerESPInstances) do
        if esp.NameLabel   then esp.NameLabel.TextSize   = size  end
        if esp.ToolLabel   then esp.ToolLabel.TextSize   = small end
        if esp.HealthLabel then esp.HealthLabel.TextSize = small end
        if esp.DistLabel   then esp.DistLabel.TextSize   = small end
    end
end

applyESPTransparency = function()
    local fillT    = espConfig.fillTransparency
    local outlineT = espConfig.outlineTransparency
    local function updateH(esp)
        if esp.Highlight and esp.Highlight.Parent then
            esp.Highlight.FillTransparency    = fillT
            esp.Highlight.OutlineTransparency = outlineT
        end
    end
    for _, sys in pairs(espSystems) do
        for _, esp in pairs(sys.instances) do updateH(esp) end
    end
    for _, esp in pairs(mobESPInstances)       do updateH(esp) end
    for _, esp in pairs(structureESPInstances) do updateH(esp) end
    for _, esp in pairs(playerESPInstances)    do updateH(esp) end
end

-- ============================================
-- CLASS AVATAR CLONER & MORPH ENGINE
-- ============================================
local HttpService = game:GetService("HttpService")
local STA_AVATARS_FILE = "SolanaHub/STA_ClassAvatars.json"
STA_ClassAvatars = {}
local _originalAvatarBackup = nil

local function _ensureSolanaHubFolder()
    pcall(function()
        if makefolder and isfolder and not isfolder("SolanaHub") then
            makefolder("SolanaHub")
        end
    end)
end

loadClassAvatarsFromFile = function()
    _ensureSolanaHubFolder()
    pcall(function()
        if readfile and isfile and isfile(STA_AVATARS_FILE) then
            local raw = readfile(STA_AVATARS_FILE)
            if raw and #raw > 0 then
                local data = HttpService:JSONDecode(raw)
                if type(data) == "table" then
                    STA_ClassAvatars = data
                end
            end
        end
    end)
end

saveClassAvatarsToFile = function()
    _ensureSolanaHubFolder()
    pcall(function()
        if writefile then
            local raw = HttpService:JSONEncode(STA_ClassAvatars)
            writefile(STA_AVATARS_FILE, raw)
        end
    end)
end

local function _isLikelyCharacterModel(model)
    if not model or not model:IsA("Model") then return false end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return false end
    end

    local hasHum = model:FindFirstChildOfClass("Humanoid") or model:FindFirstChildOfClass("AnimationController")
    local hasHead = model:FindFirstChild("Head", true) or model:FindFirstChild("Torso", true) or model:FindFirstChild("UpperTorso", true) or model:FindFirstChild("HumanoidRootPart", true)
    local hasClothing = model:FindFirstChildWhichIsA("Shirt", true) or model:FindFirstChildWhichIsA("Pants", true) or model:FindFirstChildWhichIsA("Accessory", true) or model:FindFirstChildWhichIsA("BodyColors", true) or model:FindFirstChildWhichIsA("CharacterMesh", true)

    if (hasHum or hasHead) and (hasClothing or model:FindFirstChildWhichIsA("BasePart", true)) then
        return true
    end

    return false
end

local function _serializeCharacterAvatar(model)
    if not model or not model:IsA("Model") then return nil end
    local data = {
        Shirt = nil,
        Pants = nil,
        ShirtGraphic = nil,
        Face = nil,
        BodyColors = nil,
        Accessories = {}
    }

    local shirt = model:FindFirstChildWhichIsA("Shirt", true)
    if shirt and shirt.ShirtTemplate ~= "" then data.Shirt = shirt.ShirtTemplate end

    local pants = model:FindFirstChildWhichIsA("Pants", true)
    if pants and pants.PantsTemplate ~= "" then data.Pants = pants.PantsTemplate end

    local sGraphic = model:FindFirstChildWhichIsA("ShirtGraphic", true)
    if sGraphic and sGraphic.Graphic ~= "" then data.ShirtGraphic = sGraphic.Graphic end

    local bc = model:FindFirstChildWhichIsA("BodyColors", true)
    if bc then
        data.BodyColors = {
            HeadColor3 = { bc.HeadColor3.R, bc.HeadColor3.G, bc.HeadColor3.B },
            TorsoColor3 = { bc.TorsoColor3.R, bc.TorsoColor3.G, bc.TorsoColor3.B },
            LeftArmColor3 = { bc.LeftArmColor3.R, bc.LeftArmColor3.G, bc.LeftArmColor3.B },
            RightArmColor3 = { bc.RightArmColor3.R, bc.RightArmColor3.G, bc.RightArmColor3.B },
            LeftLegColor3 = { bc.LeftLegColor3.R, bc.LeftLegColor3.G, bc.LeftLegColor3.B },
            RightLegColor3 = { bc.RightLegColor3.R, bc.RightLegColor3.G, bc.RightLegColor3.B },
        }
    else
        local head = model:FindFirstChild("Head", true)
        local torso = model:FindFirstChild("Torso", true) or model:FindFirstChild("UpperTorso", true)
        if head and head:IsA("BasePart") then
            local c = head.Color
            data.BodyColors = {
                HeadColor3 = { c.R, c.G, c.B },
                TorsoColor3 = torso and torso:IsA("BasePart") and { torso.Color.R, torso.Color.G, torso.Color.B } or { c.R, c.G, c.B },
                LeftArmColor3 = { c.R, c.G, c.B },
                RightArmColor3 = { c.R, c.G, c.B },
                LeftLegColor3 = { c.R, c.G, c.B },
                RightLegColor3 = { c.R, c.G, c.B },
            }
        end
    end

    local head = model:FindFirstChild("Head", true)
    if head and head:IsA("BasePart") then
        for _, decal in ipairs(head:GetChildren()) do
            if decal:IsA("Decal") and (decal.Name == "face" or decal.Face == Enum.NormalId.Front) then
                if decal.Texture ~= "" then data.Face = decal.Texture; break end
            end
        end
    end

    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("Accessory") then
            local handle = obj:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                local att = handle:FindFirstChildOfClass("Attachment")
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                local accData = {
                    Name = obj.Name,
                    AttachmentName = att and att.Name or "HatAttachment",
                    AttachmentCFrame = att and { att.CFrame:GetComponents() } or nil,
                    MeshId = mesh and mesh.MeshId or (handle:IsA("MeshPart") and handle.MeshId or ""),
                    TextureId = mesh and mesh.TextureId or (handle:IsA("MeshPart") and handle.TextureID or ""),
                    MeshType = mesh and mesh.MeshType.Name or "FileMesh",
                    Scale = mesh and { mesh.Scale.X, mesh.Scale.Y, mesh.Scale.Z } or { 1, 1, 1 },
                    Offset = mesh and { mesh.Offset.X, mesh.Offset.Y, mesh.Offset.Z } or { 0, 0, 0 },
                    Color = { handle.Color.R, handle.Color.G, handle.Color.B },
                    Size = { handle.Size.X, handle.Size.Y, handle.Size.Z }
                }
                table.insert(data.Accessories, accData)
            end
        end
    end

    if #data.Accessories == 0 then
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") and not (part.Name == "Head" or part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name:find("Arm") or part.Name:find("Leg") or part.Name == "HumanoidRootPart") then
                local mesh = part:FindFirstChildOfClass("SpecialMesh")
                local meshId = mesh and mesh.MeshId or (part:IsA("MeshPart") and part.MeshId or "")
                if meshId ~= "" then
                    local weld = part:FindFirstChildOfClass("Weld") or part:FindFirstChildOfClass("WeldConstraint") or part:FindFirstChildOfClass("Motor6D")
                    local targetPartName = "Head"
                    if weld and weld:IsA("Weld") and weld.Part1 then
                        targetPartName = weld.Part1.Name
                    end
                    local accData = {
                        Name = part.Name,
                        AttachmentName = targetPartName:find("Torso") and "BodyFrontAttachment" or "HatAttachment",
                        AttachmentCFrame = weld and weld:IsA("Weld") and { weld.C1:GetComponents() } or nil,
                        MeshId = meshId,
                        TextureId = mesh and mesh.TextureId or (part:IsA("MeshPart") and part.TextureID or ""),
                        MeshType = mesh and mesh.MeshType.Name or "FileMesh",
                        Scale = mesh and { mesh.Scale.X, mesh.Scale.Y, mesh.Scale.Z } or { 1, 1, 1 },
                        Offset = mesh and { mesh.Offset.X, mesh.Offset.Y, mesh.Offset.Z } or { 0, 0, 0 },
                        Color = { part.Color.R, part.Color.G, part.Color.B },
                        Size = { part.Size.X, part.Size.Y, part.Size.Z }
                    }
                    table.insert(data.Accessories, accData)
                end
            end
        end
    end

    return data
end

local function _backupMyOriginalAvatar()
    if _originalAvatarBackup then return end
    local char = LocalPlayer.Character
    if char then
        _originalAvatarBackup = _serializeCharacterAvatar(char)
    end
end

local _NON_CLASS_BLACKLIST = {
    "zombie", "mob", "boss", "brute", "crawler", "spitter", "runner", "tank",
    "crate", "perk", "barrel", "chest", "generator", "turret", "drop", "item",
    "pickup", "vehicle", "spawn", "door", "light", "tree", "building", "structure",
    "shop", "stand", "tent", "fence", "barricade", "sandbag", "military", "zone",
    "mock", "dummy_target", "car", "truck", "helicopter", "plane", "ladder"
}

local function _isBlacklistedClassName(name)
    if type(name) ~= "string" or #name < 2 then return true end
    local lower = string.lower(name)
    for _, bad in ipairs(_NON_CLASS_BLACKLIST) do
        if lower:find(bad) then
            return true
        end
    end
    return false
end

scanLobbyClassAvatars = function()
    local foundCount = 0
    local ignoredPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then ignoredPlayers[p.Character] = true end
    end

    local scannedModels = {}

    local function _evaluateModel(model)
        if not model or not model:IsA("Model") then return end
        if ignoredPlayers[model] or scannedModels[model] then return end

        local className = model.Name
        if _isBlacklistedClassName(className) then return end

        if _isLikelyCharacterModel(model) then
            scannedModels[model] = true
            local serialized = _serializeCharacterAvatar(model)
            if serialized and (#serialized.Accessories > 0 or serialized.Shirt or serialized.Pants or serialized.Face) then
                STA_ClassAvatars[className] = serialized
                foundCount = foundCount + 1
                print("[SolanaHub Class Avatar] Ditemukan class: " .. className)
            end
        end
    end

    -- 1. Direct children of Workspace (e.g. workspace.Stalker)
    for _, child in ipairs(Workspace:GetChildren()) do
        _evaluateModel(child)
    end

    -- 2. All descendants in Workspace (deep scan)
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("Model") then
            _evaluateModel(desc)
        end
    end

    -- 3. All descendants in ReplicatedStorage (some games store class models in ReplicatedStorage)
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc:IsA("Model") then
            _evaluateModel(desc)
        end
    end

    if foundCount > 0 then
        saveClassAvatarsToFile()
    end
    return foundCount
end

applyClassAvatar = function(avatarData)
    if not avatarData or type(avatarData) ~= "table" then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    _backupMyOriginalAvatar()

    -- 1. Remove existing clothing & accessories
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
            pcall(function() obj:Destroy() end)
        end
    end

    -- 2. Apply BodyColors
    if avatarData.BodyColors then
        local bc = char:FindFirstChildOfClass("BodyColors")
        if not bc then
            bc = Instance.new("BodyColors")
            bc.Parent = char
        end
        pcall(function()
            local c = avatarData.BodyColors
            if c.HeadColor3 then bc.HeadColor3 = Color3.new(unpack(c.HeadColor3)) end
            if c.TorsoColor3 then bc.TorsoColor3 = Color3.new(unpack(c.TorsoColor3)) end
            if c.LeftArmColor3 then bc.LeftArmColor3 = Color3.new(unpack(c.LeftArmColor3)) end
            if c.RightArmColor3 then bc.RightArmColor3 = Color3.new(unpack(c.RightArmColor3)) end
            if c.LeftLegColor3 then bc.LeftLegColor3 = Color3.new(unpack(c.LeftLegColor3)) end
            if c.RightLegColor3 then bc.RightLegColor3 = Color3.new(unpack(c.RightLegColor3)) end
        end)
    end

    -- 3. Apply Shirt & Pants
    if avatarData.Shirt then
        local s = Instance.new("Shirt")
        s.Name = "ClassShirt"
        s.ShirtTemplate = avatarData.Shirt
        s.Parent = char
    end
    if avatarData.Pants then
        local p = Instance.new("Pants")
        p.Name = "ClassPants"
        p.PantsTemplate = avatarData.Pants
        p.Parent = char
    end
    if avatarData.ShirtGraphic then
        local sg = Instance.new("ShirtGraphic")
        sg.Name = "ClassShirtGraphic"
        sg.Graphic = avatarData.ShirtGraphic
        sg.Parent = char
    end

    -- 4. Apply Face Decal
    local head = char:FindFirstChild("Head")
    if head and avatarData.Face then
        local face = head:FindFirstChild("face") or head:FindFirstChildOfClass("Decal")
        if not face then
            face = Instance.new("Decal")
            face.Name = "face"
            face.Face = Enum.NormalId.Front
            face.Parent = head
        end
        face.Texture = avatarData.Face
    end

    -- 5. Attach Accessories
    if avatarData.Accessories and #avatarData.Accessories > 0 then
        for _, accData in ipairs(avatarData.Accessories) do
            pcall(function()
                local acc = Instance.new("Accessory")
                acc.Name = accData.Name or "ClassAccessory"

                local handle = Instance.new("Part")
                handle.Name = "Handle"
                handle.Size = accData.Size and Vector3.new(unpack(accData.Size)) or Vector3.new(1, 1, 1)
                handle.CanCollide = false
                handle.Massless = true
                if accData.Color then
                    handle.Color = Color3.new(unpack(accData.Color))
                end

                if accData.MeshId and accData.MeshId ~= "" then
                    local sm = Instance.new("SpecialMesh")
                    sm.MeshId = accData.MeshId
                    sm.TextureId = accData.TextureId or ""
                    if accData.MeshType and Enum.MeshType[accData.MeshType] then
                        sm.MeshType = Enum.MeshType[accData.MeshType]
                    else
                        sm.MeshType = Enum.MeshType.FileMesh
                    end
                    sm.Scale = accData.Scale and Vector3.new(unpack(accData.Scale)) or Vector3.new(1, 1, 1)
                    sm.Offset = accData.Offset and Vector3.new(unpack(accData.Offset)) or Vector3.new(0, 0, 0)
                    sm.Parent = handle
                end

                handle.Parent = acc

                -- Find attachment point on character
                local targetAtt = nil
                local attName = accData.AttachmentName or "HatAttachment"
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        local a = part:FindFirstChild(attName)
                        if a and a:IsA("Attachment") then
                            targetAtt = a
                            break
                        end
                    end
                end

                local parentPart = targetAtt and targetAtt.Parent or head or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                if parentPart then
                    local weld = Instance.new("Weld")
                    weld.Name = "AccessoryWeld"
                    weld.Part0 = handle
                    weld.Part1 = parentPart

                    if targetAtt then
                        weld.C0 = accData.AttachmentCFrame and CFrame.new(unpack(accData.AttachmentCFrame)) or CFrame.new()
                        weld.C1 = targetAtt.CFrame
                    else
                        weld.C0 = CFrame.new()
                        weld.C1 = CFrame.new(0, 0.5, 0)
                    end
                    weld.Parent = handle
                end

                acc.Parent = char
            end)
        end
    end

    return true
end

resetToOriginalAvatar = function()
    if _originalAvatarBackup then
        applyClassAvatar(_originalAvatarBackup)
        Library:Notify({ Title = "Class Avatar", Description = "Avatar dikembalikan ke semula", Time = 2 })
    else
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                local desc = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
                if desc then hum:ApplyDescription(desc) end
            end
        end)
        Library:Notify({ Title = "Class Avatar", Description = "Default avatar dimuat ulang", Time = 2 })
    end
end

end
_initClassAvatarCloner()

-- ============================================
-- UI: VISUALS TAB
-- ============================================
local function _buildVisualsTab()

-- Helper: apply Name/Distance to all ESP systems at once
setAllESPNames = function(state)
    mobOptions.Name = state; refreshMobESP()
    playerESPVars.Name = state; refreshPlayerESP()
    structureESPVars.Name = state; refreshStructureESP()
    for _, sys in pairs(espSystems) do sys.vars.Name = state; sys.refresh() end
end
setAllESPDistance = function(state)
    mobOptions.Distance = state; refreshMobESP()
    playerESPVars.Distance = state; refreshPlayerESP()
    structureESPVars.Distance = state; refreshStructureESP()
    for _, sys in pairs(espSystems) do sys.vars.Distance = state; sys.refresh() end
end

-- ESP Settings (Left)  - Â  shared controls for all ESP systems
local visualsTabbox = Tabs.Visuals:AddCenterTabbox("Visuals Manager")

local espSettingsTab = visualsTabbox:AddTab({ Name = "ESP Settings", Icon = "solar:settings-bold" })
local espHighlightsTab = visualsTabbox:AddTab({ Name = "ESP Highlights", Icon = "solar:eye-bold" })
local containersStructsTab = visualsTabbox:AddTab({ Name = "Containers & Structs", Icon = "solar:box-bold" })

espSettingsGroup = espSettingsTab
espSettingsGroup:AddDivider({ Text = "ESP Display Settings" })

espSettingsGroup:AddSlider("ESPMaxDistance", {
    Text = "Max Distance", Default = 300, Min = 50, Max = 2000, Rounding = 0, Suffix = " studs",
    Tooltip = "Maximum render distance shared by all ESP systems.",
    Callback = function()
        refreshMobESP(); refreshPlayerESP(); refreshStructureESP()
        for _, sys in pairs(espSystems) do sys.refresh() end
    end,
})
espSettingsGroup:AddToggle("ESPShowNames",    { Text = "Show Names",    Default = false, Tooltip = "Show labels on all ESPs.", Callback = function(s) setAllESPNames(s)     end })
espSettingsGroup:AddToggle("ESPShowDistance", { Text = "Show Distance", Default = false, Tooltip = "Show distance on all ESPs.", Callback = function(s) setAllESPDistance(s) end })

-- [FIX #3] Text Size slider  - Â  live-updates all ESP label sizes
espSettingsGroup:AddSlider("ESPTextSize", {
    Text = "Text Size", Default = 10, Min = 8, Max = 24, Rounding = 0, Suffix = "px",
    Tooltip = "Font size for all ESP labels. Lower = less cluttered screen.",
    Callback = function(v) applyESPTextSize(v) end,
})
-- [FIX #4] Fill Transparency  - Â  controls how solid the Chams highlight fill is
espSettingsGroup:AddSlider("ESPFillTransparency", {
    Text = "Fill Transparency", Default = 40, Min = 0, Max = 100, Rounding = 0, Suffix = "%",
    Tooltip = "Chams fill opacity for all ESP. 0% = fully solid, 100% = invisible fill (outline only).",
    Callback = function(v) espConfig.fillTransparency = v / 100; applyESPTransparency() end,
})
-- [FIX #4] Outline Transparency
espSettingsGroup:AddSlider("ESPOutlineTransparency", {
    Text = "Outline Transparency", Default = 0, Min = 0, Max = 100, Rounding = 0, Suffix = "%",
    Tooltip = "Chams outline opacity for all ESP. 0% = fully solid outline.",
    Callback = function(v) espConfig.outlineTransparency = v / 100; applyESPTransparency() end,
})

espSettingsGroup:AddDivider({ Text = "Alerts" })

espSettingsGroup:AddToggle("BossAlert", {
    Text = "Boss / Brute Alert", Default = false, Tooltip = "Send UI notification when a Boss or Brute spawns.",
    Callback = function(s)
        if s then
            STA_E.startBossAlert()
            Library:Notify({ Title = "Boss Alert", Description = "ON | Monitoring spawns", Time = 2 })
        else
            STA_E.stopBossAlert()
            Library:Notify({ Title = "Boss Alert", Description = "OFF", Time = 2 })
        end
    end,
})

-- Mob ESP (Left)
local mobESPGroup = espHighlightsTab
mobESPGroup:AddDivider({ Text = "Entities ESP" })
mobESPGroup:AddToggle("MobESP",   { Text = "Mob ESP", Default = false, Tooltip = "Highlight zombies/monsters through walls.", Callback = function(s) mobOptions.ESP   = s; refreshMobESP() end })
mobESPGroup:AddToggle("MobChams", { Text = "Chams",   Default = false, Callback = function(s) mobOptions.Chams = s; refreshMobESP() end })

-- Player ESP (Left)
local playerESPGroup = espHighlightsTab
playerESPGroup:AddDivider({ Text = "Players ESP" })
playerESPGroup:AddToggle("PlayerESP",    { Text = "Player ESP",   Default = false, Callback = function(s) playerESPVars.ESP    = s; refreshPlayerESP() end })
playerESPGroup:AddToggle("PlayerChams",  { Text = "Chams",         Default = false, Callback = function(s) playerESPVars.Chams  = s; refreshPlayerESP() end })
playerESPGroup:AddToggle("PlayerHealth", { Text = "Show Health",   Default = false, Tooltip = "Health bar + HP above players.", Callback = function(s) playerESPVars.Health = s; refreshPlayerESP() end })

-- Item ESP (Right)  - Â  all categories + structures in one groupbox
local itemESPGroup = espHighlightsTab

itemESPGroup:AddDivider({ Text = "Items ESP" })
itemESPGroup:AddToggle("ItemESPChams", {
    Text = "Chams (All Categories)", Default = false,
    Tooltip = "Chams highlight for all item categories, structures, and containers.",
    Callback = function(s)
        for _, sys in pairs(espSystems) do sys.vars.Chams = s; sys.refresh() end
        structureESPVars.Chams = s; refreshStructureESP()
        containerESP.vars.crates.Chams = s; containerESP.refreshCrates()
        containerESP.vars.barrel.Chams = s; containerESP.refreshBarrel()
        containerESP.vars.emerald.Chams = s; containerESP.refreshEmerald()
    end,
})

local itemESPDefs = {
    { key = "Gun",      text = "Gun ESP",        tip = "Guns (Red)" },
    { key = "Melee",    text = "Melee ESP",       tip = "Melee (Orange)" },
    { key = "Medical",  text = "Medical ESP",     tip = "Medical Items (Green)" },
    { key = "Armor",    text = "Armor ESP",       tip = "Armor (Blue)" },
    { key = "Food",     text = "Food ESP",        tip = "Food (Lime)" },
    { key = "Resource", text = "Resources ESP",   tip = "Resources (Cyan)" },
    { key = "Fuel",     text = "Fuel ESP",        tip = "Fuel (Gold)" },
    { key = "Ability",  text = "Abilities ESP",   tip = "Abilities (Purple)" },
}
for _, d in ipairs(itemESPDefs) do
    -- [FIX #4] Color picker chained to each category toggle for live color control
    itemESPGroup:AddToggle(d.key .. "ESPEnabled", {
        Text = d.text, Default = false, Tooltip = d.tip,
        Callback = function(s) espSystems[d.key].vars.ESP = s; espSystems[d.key].refresh() end,
    }):AddColorPicker(d.key .. "ESPColor", {
        Default = espSystems[d.key].colors.fill,
        Title = d.text .. " Color",
        Callback = function(c)
            espSystems[d.key].colors.fill = c
            for _, esp in pairs(espSystems[d.key].instances) do
                if esp.Highlight and esp.Highlight.Parent then esp.Highlight.FillColor = c end
                if esp.NameLabel then esp.NameLabel.TextColor3 = c end
            end
        end,
    })
end

local containersStructsGroup = containersStructsTab

containersStructsGroup:AddDivider({ Text = "Structures" })
containersStructsGroup:AddToggle("StructureESP", { Text = "Structure ESP", Default = false, Callback = function(s) structureESPVars.ESP = s; refreshStructureESP() end }):AddColorPicker("StructureColor", {
    Default = structureESPVars.Color, Title = "Structure Color",
    Callback = function(c)
        structureESPVars.Color = c
        for _, esp in pairs(structureESPInstances) do
            if esp.Highlight then esp.Highlight.FillColor = c; esp.Highlight.OutlineColor = c end
            if esp.NameLabel then esp.NameLabel.TextColor3 = c end
        end
    end
})

containersStructsGroup:AddDivider({ Text = "Containers" })

containersStructsGroup:AddToggle("CratesESP", { Text = "ESP Crates", Default = false, Callback = function(s) containerESP.vars.crates.ESP = s; containerESP.refreshCrates() end }):AddColorPicker("CratesColor", {
    Default = containerESP.vars.crates.Color, Title = "Crates Color",
    Callback = function(c)
        containerESP.vars.crates.Color = c
        for _, esp in pairs(containerESP.instances.crates) do
            if esp.Highlight then esp.Highlight.FillColor = c; esp.Highlight.OutlineColor = c end
            if esp.NameLabel then esp.NameLabel.TextColor3 = c end
        end
    end
})

containersStructsGroup:AddToggle("BarrelESP", { Text = "ESP Barrel", Default = false, Callback = function(s) containerESP.vars.barrel.ESP = s; containerESP.refreshBarrel() end }):AddColorPicker("BarrelColor", {
    Default = containerESP.vars.barrel.Color, Title = "Barrel Color",
    Callback = function(c)
        containerESP.vars.barrel.Color = c
        for _, esp in pairs(containerESP.instances.barrel) do
            if esp.Highlight then esp.Highlight.FillColor = c; esp.Highlight.OutlineColor = c end
            if esp.NameLabel then esp.NameLabel.TextColor3 = c end
        end
    end
})

containersStructsGroup:AddToggle("EmeraldESP", { Text = "ESP Emerald Crates", Default = false, Callback = function(s) containerESP.vars.emerald.ESP = s; containerESP.refreshEmerald() end }):AddColorPicker("EmeraldColor", {
    Default = containerESP.vars.emerald.Color, Title = "Emerald Color",
    Callback = function(c)
        containerESP.vars.emerald.Color = c
        for _, esp in pairs(containerESP.instances.emerald) do
            if esp.Highlight then esp.Highlight.FillColor = c; esp.Highlight.OutlineColor = c end
            if esp.NameLabel then esp.NameLabel.TextColor3 = c end
        end
    end
})

end
_buildVisualsTab()

-- ============================================
-- UI: PLAYER TAB
-- ============================================
local function _buildPlayerTab()

movementGroup = Tabs.Player:AddCenterGroupbox("Movement", "move")

-- ============================================
-- SPEED HACK v8  - Â Clean WalkSpeed (Normal Walking)
-- Dikembalikan ke metode WalkSpeed murni sesuai permintaan agar
-- tidak terlihat "melayang". Karena batas kecepatan 100% ditentukan
-- oleh server, user DILARANG menyetel slider terlalu tinggi (>22).
-- ============================================
local speedHackConn = nil
local speedHackChangeSig = nil

local function _cleanSH(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, n in ipairs({"SOLANA HUB_SPEED_BV7", "SOLANA HUB_SPEED_BG7", "SOLANA HUB_SPEED_BV6", "SOLANA HUB_SPEED_BG5", "SOLANA HUB_SPEED_BV5", "SOLANA HUB_SPEED_BV4", "SOLANA HUB_SPEED_BV", "NX_SPEED_BV"}) do
            local inst = hrp:FindFirstChild(n)
            if inst then inst:Destroy() end
        end
    end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local function startSpeedHack()
    if speedHackConn then speedHackConn:Disconnect(); speedHackConn = nil end
    if speedHackChangeSig then speedHackChangeSig:Disconnect(); speedHackChangeSig = nil end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    _cleanSH(char)

    -- Layer 1: Sinkronisasi instan saat Server/AC mencoba reset WalkSpeed
    speedHackChangeSig = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if not (Toggles.SpeedHack and Toggles.SpeedHack.Value) then return end
        local desired = Options.SpeedValue and Options.SpeedValue.Value or 20
        if hum.WalkSpeed ~= desired then
            hum.WalkSpeed = desired
        end
    end)

    -- Layer 2: Penjaga konstan tiap frame (berjaga-jaga jika signal gagal)
    speedHackConn = RunService.Heartbeat:Connect(function()
        if not (Toggles.SpeedHack and Toggles.SpeedHack.Value) then return end
        local c2 = LocalPlayer.Character
        local h2 = c2 and c2:FindFirstChildOfClass("Humanoid")
        if not h2 or h2.Health <= 0 then return end

        local desired = Options.SpeedValue and Options.SpeedValue.Value or 20
        if h2:GetAttribute("WalkSpeed") ~= desired then
            h2:SetAttribute("WalkSpeed", desired)
        end
    end)

    -- Terapkan kecepatan pertama kali
    local initialSpeed = Options.SpeedValue and Options.SpeedValue.Value or 20
    hum:SetAttribute("WalkSpeed", initialSpeed)
end

local function stopSpeedHack()
    if speedHackConn then speedHackConn:Disconnect(); speedHackConn = nil end
    if speedHackChangeSig then speedHackChangeSig:Disconnect(); speedHackChangeSig = nil end
    local char = LocalPlayer.Character
    if char then
        char:SetAttribute("WalkSpeed", nil)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        _cleanSH(char)
    end
end

-- ============================================
-- FORCE WEAPON ABILITY & GOD MODE (Merged)
-- ============================================
STA_E.originalStats = STA_E.originalStats or setmetatable({}, {__mode = "k"})

STA_E.forceAbilityConn = RunService.Heartbeat:Connect(function()
    local doForce = Toggles.ForceWeaponAbility and Toggles.ForceWeaponAbility.Value
    local doGodMode = Toggles.OverpowerWeaponAbility and Toggles.OverpowerWeaponAbility.Value
    
    if not doForce and not doGodMode then return end

    local char = LocalPlayer.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local stats = tool:FindFirstChild("Stats")
    if not stats then return end

    -- Backup original stats if not already backed up
    if not STA_E.originalStats[tool] then
        STA_E.originalStats[tool] = stats:GetAttributes()
    end

    local orig = STA_E.originalStats[tool]
    local targetAbility = Options.WeaponAbilityType and Options.WeaponAbilityType.Value or "None"

    -- Apply the Upgrade string attribute for UI
    if doForce and targetAbility ~= "None" then
        if tool:GetAttribute("Upgrade") ~= targetAbility then
            tool:SetAttribute("Upgrade", targetAbility)
        end
    else
        if tool:GetAttribute("Upgrade") ~= nil then
            tool:SetAttribute("Upgrade", nil)
        end
    end

    -- We will build the new stats table based on original stats
    local newStats = {}
    for k, v in pairs(orig) do
        newStats[k] = v
    end

    -- If Force is on, fetch the ability stats from WeaponUpgrades module
    if doForce and targetAbility ~= "None" then
        pcall(function()
            local wpMods = require(game:GetService("ReplicatedStorage"):WaitForChild("GameInfo"):WaitForChild("WeaponUpgrades"))
            local abilityData = (wpMods.Gun and wpMods.Gun[targetAbility]) or (wpMods.Melee and wpMods.Melee[targetAbility])
            
            if abilityData then
                if abilityData.StatBoosts then
                    for k, boost in pairs(abilityData.StatBoosts) do
                        newStats[k] = (newStats[k] or 0) + boost
                    end
                end
                if abilityData.StatMultipliers then
                    for k, mult in pairs(abilityData.StatMultipliers) do
                        if newStats[k] then
                            newStats[k] = newStats[k] * mult
                        end
                    end
                end
            end
        end)
    end

    -- If God Mode is on, overwrite everything to OP levels
    if doGodMode then
        if newStats["FireRate"] then newStats["FireRate"] = 9999 end
        if newStats["ReloadTime"] then
            newStats["ReloadTime"] = 0.01
            newStats["ReloadEndTime"] = 0.01
            newStats["ReloadIndividualTime"] = 0.01
        end
        if newStats["Recoil"] then newStats["Recoil"] = 0 end
        if newStats["Inaccuracy"] then newStats["Inaccuracy"] = 0 end
        if newStats["ChargeTime"] then newStats["ChargeTime"] = 0.01 end
        if newStats["WindUp"] then newStats["WindUp"] = 0.01 end
        if newStats["Endlag"] then newStats["Endlag"] = 0.01 end
        if newStats["AnimSpeed"] then newStats["AnimSpeed"] = 100 end
    end

    -- Apply the changes ONLY if they differ from current attributes to avoid lag
    for k, v in pairs(newStats) do
        if stats:GetAttribute(k) ~= v then
            stats:SetAttribute(k, v)
        end
    end
end)

LocalPlayer.CharacterRemoving:Connect(function(char)
    _cleanSH(char)
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    if Toggles.SpeedHack and Toggles.SpeedHack.Value then
        task.wait(0.5)  -- tunggu character load
        startSpeedHack()
    end
end)

movementGroup:AddDivider({ Text = "Speed & Sprint" })

movementGroup:AddToggle("SpeedHack", {
    Premium = true,
    Text = "Speed Hack",
    Default = false,
    Callback = function(state)
        if state then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    startSpeedHack()
                end
            end
            Library:Notify({ Title = "Speed Hack", Description = "ON - Normal Walk", Time = 2 })
        else
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    stopSpeedHack()
                end
            end
            Library:Notify({ Title = "Speed Hack", Description = "OFF", Time = 2 })
        end
    end,
})

movementGroup:AddSlider("SpeedValue", {
    Text = "Walk Speed",
    Default = 33,
    Min = 16,
    Max = 33,
    Rounding = 0,
    Suffix = " studs/s",
    Tooltip = "Max safe limit is 33 to prevent rollback.",
})

movementGroup:AddToggle("AutoSprint", {
    Text = "Auto Sprint",
    Default = false,
    Callback = function(state)
        if state then
            startAutoSprint()
            Library:Notify({ Title = "Auto Sprint", Description = "ON", Time = 2 })
        else
            stopAutoSprint()
            Library:Notify({ Title = "Auto Sprint", Description = "OFF", Time = 2 })
        end
    end,
})

movementGroup:AddDivider({ Text = "Fly & Noclip" })

movementGroup:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Callback = function(state)
        if state then
            startFly()
            Library:Notify({ Title = "Fly", Description = "ON | WASD + Space/Shift", Time = 3 })
        else
            stopFly()
            Library:Notify({ Title = "Fly", Description = "OFF", Time = 2 })
        end
    end,
})

movementGroup:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Suffix = " studs/s",
})

movementGroup:AddToggle("NoClip", {
    Text = "NoClip",
    Default = false,
    Callback = function(state)
        Library:Notify({
            Title = state and "[Ghost] NoClip" or "NoClip",
            Description = state and "[+] Enabled" or "[-] Disabled",
            Time = 2,
        })
    end,
})

movementGroup:AddDivider({ Text = "Jump & Mobility" })

movementGroup:AddToggle("InfJump", {
    Text = "Inf Jump",
    Default = false,
    Callback = function(state)
        Library:Notify({
            Title = "Inf Jump",
            Description = state and "[+] Enabled" or "[-] Disabled",
            Time = 2,
        })
    end,
})

-- [ADDED v7.3] Bunny Hop toggle
movementGroup:AddToggle("BunnyHop", {
    Text = "Bunny Hop",
    Default = false,
    Tooltip = "Automatically jumps while moving for speed/momentum boost.",
    Callback = function(state)
        if state then
            startBhop()
            Library:Notify({ Title = "Bunny Hop", Description = "ON", Time = 2 })
        else
            stopBhop()
            Library:Notify({ Title = "Bunny Hop", Description = "OFF", Time = 2 })
        end
    end,
})

-- ============================================
-- CLASS AVATAR CLONER UI
-- ============================================
local avatarClonerGroup = Tabs.Player:AddCenterGroupbox("Class Avatar Cloner", "user")
avatarClonerGroup:AddDivider({ Text = "Class Avatar Presets" })

local function _getClassAvatarNames()
    local names = {}
    for name, _ in pairs(STA_ClassAvatars) do
        table.insert(names, name)
    end
    table.sort(names)
    if #names == 0 then
        table.insert(names, "None (Scan in Lobby First)")
    end
    return names
end

avatarClonerGroup:AddDropdown("SelectedClassAvatar", {
    Values = _getClassAvatarNames(),
    Default = 1,
    Multi = false,
    Text = "Select Class Avatar",
    Tooltip = "Choose a class avatar to apply.",
    Searchable = true,
})

avatarClonerGroup:AddButton("Apply Class Avatar", function()
    local selected = Options.SelectedClassAvatar and Options.SelectedClassAvatar.Value
    if not selected or selected == "" or selected:find("None") then
        Library:Notify({ Title = "Class Avatar", Description = "Scan di Lobby dulu atau pilih class yang valid!", Time = 3 })
        return
    end
    local data = STA_ClassAvatars[selected]
    if data then
        local ok = applyClassAvatar(data)
        if ok then
            Library:Notify({ Title = "Class Avatar", Description = "Avatar " .. selected .. " diterapkan!", Time = 2 })
        end
    else
        Library:Notify({ Title = "Class Avatar", Description = "Data avatar tidak ditemukan!", Time = 2 })
    end
end)

avatarClonerGroup:AddButton("Scan Lobby Classes", function()
    Library:Notify({ Title = "Class Avatar", Description = "Memindai model class di Lobby...", Time = 2 })
    local count = scanLobbyClassAvatars()
    if count > 0 then
        local newNames = _getClassAvatarNames()
        if Options.SelectedClassAvatar and Options.SelectedClassAvatar.SetValues then
            Options.SelectedClassAvatar:SetValues(newNames)
            if newNames[1] then Options.SelectedClassAvatar:SetValue(newNames[1]) end
        end
        Library:Notify({ Title = "Class Avatar", Description = count .. " model class tersimpan ke file!", Time = 3 })
    else
        Library:Notify({ Title = "Class Avatar", Description = "Tidak ada model class baru (Pastikan kamu di Lobby)", Time = 3 })
    end
end)

avatarClonerGroup:AddButton("Reset Avatar", function()
    resetToOriginalAvatar()
end)

avatarClonerGroup:AddButton("Delete Selected Class", function()
    local selected = Options.SelectedClassAvatar and Options.SelectedClassAvatar.Value
    if not selected or selected == "" or selected:find("None") then
        Library:Notify({ Title = "Class Avatar", Description = "Pilih class yang ingin dihapus!", Time = 2 })
        return
    end
    if STA_ClassAvatars[selected] then
        STA_ClassAvatars[selected] = nil
        saveClassAvatarsToFile()
        local newNames = _getClassAvatarNames()
        if Options.SelectedClassAvatar and Options.SelectedClassAvatar.SetValues then
            Options.SelectedClassAvatar:SetValues(newNames)
            if newNames[1] then Options.SelectedClassAvatar:SetValue(newNames[1]) end
        end
        Library:Notify({ Title = "Class Avatar", Description = "Class " .. selected .. " berhasil dihapus!", Time = 2 })
    end
end)

end
_buildPlayerTab()

-- ============================================
-- UI: COMBAT TAB
-- ============================================
local function _buildCombatTab()

local combatTabbox = Tabs.Combat:AddCenterTabbox("Combat Manager")
local killAuraTab = combatTabbox:AddTab({ Name = "Kill Aura", Icon = "solar:target-bold" })
local aimbotTab = combatTabbox:AddTab({ Name = "Aimbot", Icon = "lucide:crosshair" })
local hitboxAATab = combatTabbox:AddTab({ Name = "Hitbox & AA", Icon = "solar:shield-bold" })

killAuraGroup = killAuraTab
killAuraGroup:AddDivider({ Text = "Kill Aura" })

killAuraGroup:AddToggle("KillAura", {
    Premium = true,
    Text = "Kill Aura",
    Default = false,
    Tooltip = "AoE auto-attack: hits ALL mobs in range in one swing. Priority, auto-equip, and visual indicator configurable below.",
    Callback = function(state)
        if state then
            startKillAura()
            Library:Notify({ Title = "Kill Aura", Description = "ON | AoE radius active", Time = 2 })
        else
            stopKillAura()
            Library:Notify({ Title = "Kill Aura", Description = "OFF", Time = 2 })
        end
    end,
})

killAuraGroup:AddDropdown("KillAuraPriority", {
    Values = {"Nearest", "Lowest HP", "Highest HP"},
    Default = 1,
    Text = "Target Priority",
    Tooltip = "Determines which mob is attacked first (relevant for RemoteClick fallback; AoE mode hits all anyway).",
})


killAuraGroup:AddToggle("KillAuraShowIndicator", {
    Text = "Show Target Indicator",
    Default = true,
    Tooltip = "Draws a red snapline and circle to the current primary target.",
})

killAuraGroup:AddToggle("KillAuraExtendedRange", {
    Text = "Extended Range (+2 studs)",
    Default = true,
    Tooltip = "Adds 2 studs to your range. Helps the server register hits at the edge of reach.",
})

killAuraGroup:AddSlider("KillAuraRange", {
    Text = "Base Range",
    Default = 6,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Base attack distance. Extended Range adds +2 studs. Normal melee reach is ~5-7 studs.",
})

killAuraGroup:AddSlider("KillAuraSwingRate", {
    Text = "Swing Delay (s)",
    Default = 0.5,
    Min = 0.05,
    Max = 2.0,
    Rounding = 2,
    Tooltip = "Minimum delay between swings in seconds.",
})

killAuraGroup:AddDivider({ Text = "Weapon Speeds Info" })
killAuraGroup:AddLabel("Knife/Katana: 0.25 - 0.3s")
killAuraGroup:AddLabel("Bat/Hatchet: 0.4 - 0.45s")
killAuraGroup:AddLabel("Fire Axe/Sledgehammer: 0.55 - 0.6s")

-- ============================================
-- AIMBOT UI (AIM LOCK & SILENT AIM)
-- ============================================
aimbotGroup = aimbotTab

local _isPCUser = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled
local _isMobileUser = UserInputService.TouchEnabled

-- SECTION 1: AIM LOCK
aimbotGroup:AddDivider({ Text = "Aim Lock" })

aimbotGroup:AddToggle("AimLock", {
    Text = "Aim Lock",
    Default = false,
    Tooltip = "Locks your camera view onto the nearest enemy's head/body for easy manual shooting.",
    Callback = function(state)
        updateAimLockMobileButton(state)
        Library:Notify({ Title = "Aim Lock", Description = state and "ON | Camera Lock Active" or "OFF", Time = 2 })
    end,
})

if _isPCUser then
    aimbotGroup:AddLabel("Aim Lock Keybind"):AddKeyPicker("AimLockKeybind", {
        Default = "None",
        Text = "Aim Lock",
        Mode = "Toggle",
        Callback = function(state)
            if Toggles.AimLock then
                Toggles.AimLock:SetValue(state)
            end
        end,
    })
end

if _isMobileUser then
    aimbotGroup:AddToggle("AimLockMobileButton", {
        Text = "Mobile Quick Button",
        Default = true,
        Tooltip = "Shows a floating on-screen draggable button to quickly toggle Aim Lock on Mobile.",
        Callback = function(state)
            if _mobileAimBtnGui then
                _mobileAimBtnGui.Enabled = state
            end
        end,
    })

    aimbotGroup:AddToggle("AimLockLockButtonPos", {
        Text = "Lock Button Position",
        Default = false,
        Tooltip = "Locks the mobile button position (undraggable) so it cannot be moved accidentally during gameplay.",
        Callback = function(state)
            updateAimLockMobileLockState(state)
        end,
    })
end

aimbotGroup:AddDropdown("AimLockTarget", {
    Text = "Target Mode",
    Default = "Zombies",
    Values = {"Zombies", "Bandits", "Both"},
    Tooltip = "Entities to target. Zombies, Bandits (PvP/NPC), or Both.",
})

aimbotGroup:AddDropdown("AimLockPart", {
    Text = "Aim Part",
    Default = "Head",
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Tooltip = "Body part to lock onto (e.g. Head for headshots).",
})

aimbotGroup:AddSlider("AimLockSmoothness", {
    Text = "Smoothness",
    Default = 0,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Tooltip = "0 = Instant Snap to target, >0 = Smooth camera glide.",
})

aimbotGroup:AddSlider("AimLockRange", {
    Text = "Lock Distance",
    Default = 200,
    Min = 20,
    Max = 1000,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Maximum distance to detect and lock onto targets.",
})

aimbotGroup:AddToggle("AimLockWallCheck", {
    Text = "Wall Check",
    Default = true,
    Tooltip = "Only locks onto enemies that are visible (not blocked behind walls).",
})

-- SECTION 2: SILENT AIM
aimbotGroup:AddDivider({ Text = "Silent Aim" })

aimbotGroup:AddToggle("AutoShoot", {
    Text = "Silent Aim",
    Default = false,
    Tooltip = "Automatically targets and shoots enemies in range without moving your camera.",
    Callback = function(state)
        Library:Notify({ Title = "Silent Aim", Description = state and "ON | Auto Shoot & Headshot Active" or "OFF", Time = 2 })
    end,
})

aimbotGroup:AddDivider({ Text = "⚠️ IMPORTANT WARNING ⚠️" })
aimbotGroup:AddLabel("Do not use Silent Aim if you are playing")
aimbotGroup:AddLabel("as the Necromancer class, as it will")
aimbotGroup:AddLabel("target your own revived zombies.")

if _isPCUser then
    aimbotGroup:AddLabel("Silent Aim Keybind"):AddKeyPicker("SilentAimKeybind", {
        Default = "None",
        Text = "Silent Aim",
        Mode = "Toggle",
        Callback = function(state)
            if Toggles.AutoShoot then
                Toggles.AutoShoot:SetValue(state)
            end
        end,
    })
end

aimbotGroup:AddDropdown("SilentAimTarget", {
    Text = "Silent Aim Target",
    Default = "Zombies",
    Values = {"Zombies", "Bandits", "Both"},
    Tooltip = "Entities to target for Silent Aim.",
})

aimbotGroup:AddDropdown("SilentAimPart", {
    Text = "Silent Aim Part",
    Default = "Head",
    Values = {"Head", "Torso", "HumanoidRootPart"},
    Tooltip = "Body part to target for Silent Aim (e.g. Head for headshots).",
})

aimbotGroup:AddSlider("SilentAimRange", {
    Text = "Silent Aim Range",
    Default = 200,
    Min = 20,
    Max = 1000,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Maximum distance to automatically detect and shoot targets.",
})

aimbotGroup:AddToggle("SilentAimWallCheck", {
    Text = "Wall Check (Silent Aim)",
    Default = true,
    Tooltip = "Prevents shooting at zombies behind walls (saves ammo).",
})

aimbotGroup:AddDivider()

aimbotGroup:AddToggle("AutoReload", {
    Text = "Auto Reload",
    Default = false,
    Tooltip = "Automatically reloads your equipped weapon.",
})

-- ============================================
-- UI: COMBAT TAB EXTRA (Hitbox + Anti-Aim)
-- ============================================

hitboxGroup = hitboxAATab
hitboxGroup:AddDivider({ Text = "Hitbox Expander" })

hitboxGroup:AddToggle("HitboxEnabled", {
    Text = "Expand Zombie Hitboxes",
    Default = false,
    Tooltip = "Expands zombie hitboxes to make hits easier.",
    Callback = function(state)
        if state then
            STA_E.startHitbox()
            Library:Notify({ Title = "Hitbox", Description = "ON | Zombie hitbox diperbesar", Time = 2 })
        else
            STA_E.stopHitbox()
            Library:Notify({ Title = "Hitbox", Description = "OFF | Ukuran asli dikembalikan", Time = 2 })
        end
    end,
})

hitboxGroup:AddSlider("HitboxSize", {
    Text = "Hitbox Size",
    Default = 10,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Zombie hitbox size. Bigger size = easier hits.",
})

hitboxGroup:AddDivider({ Text = "Anti-Aim (Spinbot)" })

hitboxGroup:AddToggle("SpinbotEnabled", {
    Text = "Anti-Aim (HvH Spinbot)",
    Default = false,
    Tooltip = "Spins your character rapidly to make you harder to hit in PvP.",
    Callback = function(state)
        if state then
            STA_E.startSpinbot()
            Library:Notify({ Title = "Anti-Aim", Description = "ON | Spinning...", Time = 2 })
        else
            STA_E.stopSpinbot()
            Library:Notify({ Title = "Anti-Aim", Description = "OFF", Time = 2 })
        end
    end,
})

-- ============================================
-- UI: WEAPON MODS (Added v7.5)
-- ============================================
local weaponModsTab = combatTabbox:AddTab({ Name = "Weapon Mods", Icon = "solar:star-bold" })
local weaponModsGroup = weaponModsTab
weaponModsGroup:AddDivider({ Text = "Weapon Abilities" })

weaponModsGroup:AddToggle("ForceWeaponAbility", {
    Text = "Force Weapon Ability",
    Default = false,
    Tooltip = "Tricks your client into thinking your held weapon has the selected ability.",
})

weaponModsGroup:AddDropdown("WeaponAbilityType", {
    Text = "Ability to Force",
    Default = "Swift",
    Values = {"None", "Lethal", "Swift", "Piercing", "Precise", "Scattershot", "Giant"},
    Tooltip = "Select which ability you want your weapon to have.",
})

weaponModsGroup:AddDivider({ Text = "God Mode Modifiers" })

weaponModsGroup:AddToggle("OverpowerWeaponAbility", {
    Text = "God Mode Modifiers (OP)",
    Default = false,
    Tooltip = "WARNING: Modifies your equipped weapon's local stats to give insane FireRate, instant Reload, and 0 Recoil!",
})

end
_buildCombatTab()

-- ============================================
-- UI: EXPLOITS TAB
-- ============================================
local function _buildExploitsTab()

local exploitsTabbox = Tabs.Exploits:AddCenterTabbox("Exploits Manager")
local autoFarmTab = exploitsTabbox:AddTab({ Name = "Auto Farm", Icon = "solar:bolt-bold" })
local autoPickupTab = exploitsTabbox:AddTab({ Name = "Auto Pickup", Icon = "solar:magnet-bold" })
local auraUtilsTab = exploitsTabbox:AddTab({ Name = "Aura & Utils", Icon = "solar:settings-bold" })

-- LEFT: Auto Farm (Zombie + Item + Return Generator)
autoFarmGroup = autoFarmTab

autoFarmGroup:AddDivider({ Text = "Gem Farm" })

autoFarmGroup:AddToggle("GemFarmToggle", {
    Premium = true,
    Text = "Auto Farm Gems (Solo)",
    Default = false,
    Tooltip = "Automatically collects fuels, teleports them to the generator, repairs the Power Plant, and votes Play Again to farm Gems. Optimized for solo servers.",
    Callback = function(state)
        if state then
            startAutoFarmGem()
            Library:Notify({ Title = "Auto Farm Gem", Description = "ON | Initiating gem farm pipeline", Time = 2 })
        else
            stopAutoFarmGem()
            Library:Notify({ Title = "Auto Farm Gem", Description = "OFF", Time = 2 })
        end
    end,
})

autoFarmGroup:AddToggle("GemFarmSoloProtection", {
    Premium = true,
    Text = "Solo Server Protection",
    Default = true,
    Tooltip = "Instantly kicks you or votes Play Again if another player joins the server during Gem farming.",
})

autoFarmGroup:AddDivider({ Text = "Zombie & Item Farm" })

autoFarmGroup:AddToggle("AutoFarmZombies", {
    Premium = true,
    Text = "Auto Farm Zombies",
    Default = false,
    Tooltip = "Automatically chases and attacks the nearest zombie. Kill Aura must be enabled for damage.",
    Callback = function(state)
        if state then
            Library:Notify({ Title = "Auto Farm Zombies", Description = "ON | Bot chasing zombies", Time = 2 })
        else
            Library:Notify({ Title = "Auto Farm Zombies", Description = "OFF", Time = 2 })
        end
        _checkFarmToggle()
    end,
})

autoFarmGroup:AddToggle("AutoFarmItems", {
    Premium = true,
    Text = "Auto Farm Items",
    Default = false,
    Tooltip = "Automatically chases and collects filtered items. Stops automatically when your backpack is full.",
    Callback = function(state)
        if state then
            _G.STA_BagFull = false -- [FIX] Reset status tas saat dinyalakan
            Library:Notify({ Title = "Auto Farm Items", Description = "ON | Bot collecting items", Time = 2 })
        else
            Library:Notify({ Title = "Auto Farm Items", Description = "OFF", Time = 2 })
        end
        _checkFarmToggle()
    end,
})

autoFarmGroup:AddToggle("AutoReturnGenerator", {
    Text = "Auto Return to Generator (Backpack Full)",
    Default = false,
    Tooltip = "When backpack is full, your character auto-flies to the Generator to deposit. Farming resumes after deposit.",
    Callback = function(state)
        if state then
            Library:Notify({ Title = "Auto Return Gen", Description = "ON | Auto deposit", Time = 2 })
        else
            Library:Notify({ Title = "Auto Return Gen", Description = "OFF", Time = 2 })
        end
        _checkFarmToggle()
    end,
})

autoFarmGroup:AddDivider({ Text = "Farm Configurations" })

autoFarmGroup:AddSlider("FarmHoverHeight", {
    Text = "Hover Height",
    Default = 8,
    Min = 2,
    Max = 50,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Vertical hover distance above zombie/item targets.",
})


autoFarmGroup:AddSlider("FarmMoveSpeed", {
    Text = "Farm Move Speed",
    Default = 1,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Tooltip = "CFrame lerp speed while chasing targets. Higher = faster.",
})

-- LEFT: Auto Pickup (proximity-based, no player teleport)
autoPickupGroup = autoPickupTab
autoPickupGroup:AddDivider({ Text = "Pickup Settings" })

autoPickupGroup:AddToggle("AutoPickup", {
    Text = "Auto Pickup",
    Default = false,
    Tooltip = "Automatically picks up items within your radius circle. Uses C++ spatial query with zero FPS drop.",
    Callback = function(state)
        if state then
            startAutoPickup()
            local r = Options.AutoPickupRadius and Options.AutoPickupRadius.Value or 20
            Library:Notify({ Title = "Auto Pickup", Description = "ON | Radius " .. tostring(r) .. " studs", Time = 2 })
        else
            stopAutoPickup()
            Library:Notify({ Title = "Auto Pickup", Description = "OFF", Time = 2 })
        end
    end,
})

autoPickupGroup:AddSlider("AutoPickupRadius", {
    Text = "Pickup Radius",
    Default = 20,
    Min = 5,
    Max = 45,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Customize the detection circle zone around your feet.",
    Callback = function(val)
        if _pickupCirclePart and _pickupCirclePart.Parent then
            local diameter = val * 2
            _pickupCirclePart.Size = Vector3.new(diameter, 0.01, diameter)
        end
    end,
})

autoPickupGroup:AddToggle("AutoPickupAll", {
    Text = "All Items",
    Default = false,
    Tooltip = "Pick up every item in the folder. Disable to use the whitelist filter below.",
})

autoPickupGroup:AddDivider({ Text = "FE Methods" })

autoPickupGroup:AddToggle("AutoPickupMethodRemote", {
    Text = "Method A: Remote",
    Default = true,
    Tooltip = "FireServer on Remotes.Interaction.PickUpItem + AdjustBackpack. Fast, works when server has no strict distance check.",
})

autoPickupGroup:AddToggle("AutoPickupMethodTouch", {
    Text = "Method B: Touch",
    Default = true,
    Tooltip = "firetouchinterest(HRP, itemPart) - simulates the player touching the item part. Fires server-side Touched handlers.",
})

autoPickupGroup:AddToggle("AutoPickupMethodPrompt", {
    Text = "Method C: Prompt",
    Default = true,
    Tooltip = "fireproximityprompt(prompt) - fires the item's ProximityPrompt if one exists. Useful for items using prompt-based pickup.",
})

autoPickupGroup:AddDivider({ Text = "Item Whitelist" })
autoPickupGroup:AddDropdown("AutoPickupWhitelist", {
    Values = itemNames,
    Default = 1,
    Multi = true,
    Text = "Whitelist",
    Tooltip = "Items to pick up. Only active when 'All Items' is disabled.",
    Searchable = true,
})



auraUtilsTab:AddDivider({ Text = "Repair Aura" })
repairAuraGroup = auraUtilsTab

repairAuraGroup:AddToggle("RepairAura", {
    Premium = true,
    Text    = "Repair Aura",
    Default = false,
    Tooltip = "Automatically repairs structures within range. Repair Hammer must be equipped.",
    Callback = function(state)
        if state then
            startRepairAura()
            Library:Notify({ Title = "Repair Aura", Description = "ON | Range:" .. (Options.RepairAuraRange and Options.RepairAuraRange.Value or 30) .. " studs", Time = 2 })
        else
            stopRepairAura()
            Library:Notify({ Title = "Repair Aura", Description = "OFF", Time = 2 })
        end
    end,
})

repairAuraGroup:AddSlider("RepairAuraRange", {
    Text     = "Range",
    Default  = 30,
    Min      = 5,
    Max      = 30,
    Rounding = 0,
    Suffix   = " studs",
    Tooltip  = "Maximum distance to structures that will be repaired.",
})

repairAuraGroup:AddSlider("RepairAuraRate", {
    Text     = "Rate",
    Default  = 1,
    Min      = 1,
    Max      = 10,
    Rounding = 0,
    Suffix   = "/s",
    Tooltip  = "How many repair remote fires per second (1 = minimum, 10 = maximum).",
})

-- ============================================
-- UI: EXPLOITS TAB EXTRA (Flash Magnet, Auto Use, Auto Trash)
-- ============================================
-- Auto Use / Heal
auraUtilsTab:AddDivider({ Text = "Auto Use & Heal" })
autoUseGroup = auraUtilsTab

autoUseGroup:AddToggle("AutoUse", {
    Text = "Auto Use / Heal",
    Default = false,
    Tooltip = "Automatically uses selected food/medkit items from your inventory.",
    Callback = function(state)
        if state then
            STA_E.startAutoUse()
            Library:Notify({ Title = "Auto Use", Description = "ON | Auto consume aktif", Time = 2 })
        else
            -- Stop hanya jika fitur AutoUse lain juga off
            if not (Toggles.SmartAutoHeal and Toggles.SmartAutoHeal.Value)
               and not (Toggles.AutoEat and Toggles.AutoEat.Value) then
                STA_E.stopAutoUse()
            end
            Library:Notify({ Title = "Auto Use", Description = "OFF", Time = 2 })
        end
    end,
})

autoUseGroup:AddSlider("AutoUseRadius", {
    Text = "Auto Use Radius",
    Default = 15,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Scanner radius for usable items nearby.",
})

autoUseGroup:AddToggle("SmartAutoHeal", {
    Text = "Smart Auto Heal",
    Default = false,
    Tooltip = "Automatically uses medkit/bandage when HP drops below your configured percentage.",
    Callback = function(state)
        if state then
            STA_E.startAutoUse() -- shared loop, cek kedua toggle
            Library:Notify({ Title = "Smart Heal", Description = "ON | Heal otomatis saat HP rendah", Time = 2 })
        else
            -- Stop hanya jika fitur AutoUse lain juga off
            if not (Toggles.AutoUse and Toggles.AutoUse.Value)
               and not (Toggles.AutoEat and Toggles.AutoEat.Value) then
                STA_E.stopAutoUse()
            end
            Library:Notify({ Title = "Smart Heal", Description = "OFF", Time = 2 })
        end
    end,
})

autoUseGroup:AddToggle("AutoEat", {
    Text = "Auto Eat",
    Default = true,
    Tooltip = "Automatically eats food when hunger is low, but never while inside generator/base zone.",
    Callback = function(state)
        if state then
            STA_E.startAutoUse()
            Library:Notify({ Title = "Auto Eat", Description = "ON | Makan otomatis di luar base", Time = 2 })
        else
            if not (Toggles.AutoUse and Toggles.AutoUse.Value)
               and not (Toggles.SmartAutoHeal and Toggles.SmartAutoHeal.Value) then
                STA_E.stopAutoUse()
            end
            Library:Notify({ Title = "Auto Eat", Description = "OFF", Time = 2 })
        end
    end,
})

autoUseGroup:AddSlider("HungerThreshold", {
    Text = "Hunger Threshold (%)",
    Default = 85,
    Min = 10,
    Max = 95,
    Rounding = 0,
    Suffix = "%",
    Tooltip = "Auto Eat triggers when estimated hunger bar is at or below this value.",
})

autoUseGroup:AddSlider("HealThreshold", {
    Text = "Heal Threshold (%)",
    Default = 50,
    Min = 10,
    Max = 90,
    Rounding = 0,
    Suffix = "%",
    Tooltip = "HP threshold where auto-heal activates. Example: 50 = heal below 50% HP.",
})

autoUseGroup:AddDivider({ Text = "Auto Use Filter" })
autoUseGroup:AddDropdown("AutoUseFilter", {
    Values = { "Bandage", "Medkit", "Compound H", "Compound I", "Compound R", "Compound S",
               "Chips", "Carrot", "Bloxiade", "Beans", "MRE", "Bloxy Cola" },
    Multi = true,
    Text = "Item Filter",
    Tooltip = "Choose which items Auto Use is allowed to consume.",
    Searchable = true,
})

auraUtilsTab:AddDivider({ Text = "Auto Trash" })
autoTrashGroup = auraUtilsTab

autoTrashGroup:AddToggle("AutoTrash", {
    Text = "Auto Trash / Drop Item",
    Default = false,
    Tooltip = "Automatically drops low-value junk items to keep your backpack clear.",
    Callback = function(state)
        if state then
            STA_E.startAutoTrash()
            Library:Notify({ Title = "Auto Trash", Description = "ON | Junk otomatis dibuang", Time = 2 })
        else
            STA_E.stopAutoTrash()
            Library:Notify({ Title = "Auto Trash", Description = "OFF", Time = 2 })
        end
    end,
})

autoTrashGroup:AddDivider({ Text = "Auto Trash Filter" })

local function _collectAutoTrashItems()
    local set = {}
    local function addName(n)
        if type(n) ~= "string" or n == "" then return end
        if _isProtectedTrashName and _isProtectedTrashName(n) then return end
        set[n] = true
    end

    for _, n in ipairs(itemNames or {}) do addName(n) end
    for _, n in ipairs(pickupItemNames or {}) do addName(n) end

    if droppedItemsFolder then
        for _, it in ipairs(droppedItemsFolder:GetChildren()) do
            addName(it.Name)
        end
    end

    local bp = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, it in ipairs(bp:GetChildren()) do
            addName(it.Name)
        end
    end

    local char = LocalPlayer and LocalPlayer.Character
    if char then
        for _, it in ipairs(char:GetChildren()) do
            addName(it.Name)
        end
    end

    local vals = {}
    for n in pairs(set) do table.insert(vals, n) end
    table.sort(vals)
    return vals
end

local _autoTrashValuesCache = _collectAutoTrashItems()
autoTrashGroup:AddDropdown("AutoTrashFilter", {
    Values = _autoTrashValuesCache,
    Default = {},
    Multi = true,
    Text = "Trash Filter",
    Tooltip = "Select backpack items to drop. Empty filter = drop all backpack items except backpack-type. Works only near generator.",
    Searchable = true,
})

task.spawn(function()
    local lastSig = table.concat(_autoTrashValuesCache, "|")
    while task.wait(2.5) do
        if Options and Options.AutoTrashFilter and Options.AutoTrashFilter.SetValues then
            local vals = _collectAutoTrashItems()
            local sig = table.concat(vals, "|")
            if sig ~= lastSig then
                local keep = {}
                for k, v in pairs(Options.AutoTrashFilter.Value or {}) do
                    if v and not _isProtectedTrashName(k) then
                        keep[k] = true
                    end
                end
                Options.AutoTrashFilter:SetValues(vals)
                if Solt(keep) then
                    Options.AutoTrashFilter:SetValue(keep)
                end
                _autoTrashValuesCache = vals
                lastSig = sig
            end
        end
    end
end)

end
_buildExploitsTab()

-- ============================================
-- UI: MISC TAB
-- ============================================
local function _buildMiscTab()

local miscTabbox = Tabs.Misc:AddCenterTabbox("Misc Manager")
local utilitiesTab = miscTabbox:AddTab({ Name = "Utilities", Icon = "solar:settings-bold" })
local serverTeleportTab = miscTabbox:AddTab({ Name = "Server & Teleport", Icon = "solar:server-bold" })

utilityGroup = utilitiesTab
utilityGroup:AddDivider({ Text = "Visual Enhancements" })

utilityGroup:AddToggle("AntiAFK", {
    Text = "Anti-AFK",
    Default = true,
    Tooltip = "Prevents the game from kicking you for being idle",
    Callback = function(state)
        if state then
            startAntiAFK()
            Library:Notify({ Title = "Anti-AFK", Description = "ON | AFK-proof", Time = 2 })
        else
            stopAntiAFK()
            Library:Notify({ Title = "Anti-AFK", Description = "OFF", Time = 2 })
        end
    end,
})

utilityGroup:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = false,
    Tooltip = "Brightens the game world by modifying lighting properties. Restores originals when disabled.",
    Callback = function(state)
        if state then
            enableFullbright()
            Library:Notify({ Title = "Fullbright", Description = "ON | Brighter map", Time = 2 })
        else
            disableFullbright()
            Library:Notify({ Title = "Fullbright", Description = "OFF", Time = 2 })
        end
    end,
})

utilityGroup:AddToggle("RemoveFog", {
    Text = "Remove Fog",
    Default = false,
    Tooltip = "Removes visual fog for clear long-distance visibility. Restores original fog when disabled.",
    Callback = function(state)
        if state then
            enableRemoveFog()
            Library:Notify({ Title = "Remove Fog", Description = "ON | No fog", Time = 2 })
        else
            disableRemoveFog()
            Library:Notify({ Title = "Remove Fog", Description = "OFF", Time = 2 })
        end
    end,
})

utilityGroup:AddDivider({ Text = "Performance & FPS" })

utilityGroup:AddButton('Potato Mode (Clean Map)', function()
        Library:Notify({ Title = "Potato Mode", Description = "Membersihkan tekstur & material map... (Bisa lag sebentar)", Time = 3 })
        task.spawn(function()
            local count = 0
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not (v.Parent and v.Parent:FindFirstChild("Humanoid")) then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    pcall(function() v:Destroy(); count = count + 1 end)
                end
            end
            pcall(function() game.Lighting.GlobalShadows = false end)
            Library:Notify({ Title = "Potato Mode", Description = "Selesai! " .. count .. " tekstur dihapus.", Time = 3 })
        end)
    end)

utilityGroup:AddSlider("FPSCap", {
    Text = "FPS Cap",
    Default = 144,
    Min = 30,
    Max = 360,
    Rounding = 0,
    Suffix = " fps",
    Tooltip = "Set the target FPS cap. Applied when Unlock FPS is enabled.",
    Callback = function(value)
        if Toggles.FPSUnlock and Toggles.FPSUnlock.Value then
            pcall(function() if setfpscap then setfpscap(value) end end)
        end
    end,
})

utilityGroup:AddToggle("FPSUnlock", {
    Text = "Unlock FPS",
    Default = false,
    Tooltip = "Remove the default 60 FPS cap using setfpscap() executor API.",
    Callback = function(state)
        pcall(function()
            if setfpscap then
                if state then
                    local cap = Options.FPSCap and Options.FPSCap.Value or 144
                    setfpscap(cap)
                    Library:Notify({ Title = "FPS Unlocker", Description = "ON | Cap:" .. cap .. " fps", Time = 2 })
                else
                    setfpscap(60)
                    Library:Notify({ Title = "FPS Unlocker", Description = "OFF", Time = 2 })
                end
            else
                Library:Notify({ Title = "FPS Unlocker", Description = "setfpscap() not available", Time = 3 })
            end
        end)
    end,
})

-- Server Tools (Right)  - Â  merged with Base Tools + Remote Spy
serverGroup = serverTeleportTab
serverGroup:AddDivider({ Text = "Server Tools" })

serverGroup:AddButton("Server Hop", function()
    Library:Notify({ Title = "Server Hop", Description = "Looking for server...", Time = 2 })
    serverHop()
end)

serverGroup:AddButton("Rejoin Server", function()
    Library:Notify({ Title = "Rejoin", Description = "Rejoining...", Time = 2 })
    rejoinServer()
end)

serverGroup:AddDivider({ Text = "Anti Prompt" })

serverGroup:AddToggle("AutoRefuel", {
    Premium = true,
    Text = "Anti Prompt",
    Default = false,
    Tooltip = "Converts hold prompts to single-click by forcing HoldDuration=0 (crate/pump/generator prompts).",
    Callback = function(state)
        if state then
            STA_E.startAntiProximityPrompt()
            Library:Notify({ Title = "Anti ProximityPrompt", Description = "ON | Hold -> Click", Time = 2 })
        else
            STA_E.stopAntiProximityPrompt()
            Library:Notify({ Title = "Anti ProximityPrompt", Description = "OFF", Time = 2 })
        end
    end,
})

serverGroup:AddToggle("AutoOpenChest", {
    Premium = true,
    Text = "Anti Prompt V2",
    Default = false,
    Tooltip = "Automatically triggers nearby ProximityPrompts (chests, power plants, generators, etc.) when in range without clicking/holding.",
    Callback = function(state)
        if state then
            STA_E.startAutoOpenChest()
            Library:Notify({ Title = "Anti Prompt V2", Description = "ON | Radius: " .. (Options.AutoOpenChestRadius and Options.AutoOpenChestRadius.Value or 20) .. " studs", Time = 2 })
        else
            STA_E.stopAutoOpenChest()
            Library:Notify({ Title = "Anti Prompt V2", Description = "OFF", Time = 2 })
        end
    end,
})

serverGroup:AddSlider("AutoOpenChestRadius", {
    Text = "Prompt Radius",
    Default = 20,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Maximum distance to automatically trigger nearby prompts.",
})

serverGroup:AddDivider({ Text = "Teleport Tools" })

-- ============================================
-- UI: MISC TAB EXTRA (Anti Ragdoll, Auto Revive, Priority Pickup, Ctrl+Click TP)
-- ============================================
-- Player Utilities
utilitiesTab:AddDivider({ Text = "Player Utilities" })
playerUtilGroup = utilitiesTab

playerUtilGroup:AddToggle("AntiRagdoll", {
    Text = "Anti Ragdoll",
    Default = false,
    Tooltip = "Prevents ragdoll/knockdown when attacked by zombies.",
    Callback = function(state)
        if state then
            STA_E.startAntiRagdoll()
            Library:Notify({ Title = "Anti Ragdoll", Description = "ON | Ragdoll disabled", Time = 2 })
        else
            STA_E.stopAntiRagdoll()
            Library:Notify({ Title = "Anti Ragdoll", Description = "OFF", Time = 2 })
        end
    end,
})

playerUtilGroup:AddDivider({ Text = "Auto Revive" })

playerUtilGroup:AddToggle("AutoRevive", {
    Text = "Auto Revive",
    Default = false,
    Tooltip = "Automatically revives nearby downed teammates.",
    Callback = function(state)
        if state then
            STA_E.startAutoRevive()
            Library:Notify({ Title = "Auto Revive", Description = "ON | Auto revive", Time = 2 })
        else
            STA_E.stopAutoRevive()
            Library:Notify({ Title = "Auto Revive", Description = "OFF", Time = 2 })
        end
    end,
})

playerUtilGroup:AddSlider("ReviveRadius", {
    Text = "Revive Radius",
    Default = 15,
    Min = 5,
    Max = 50,
    Rounding = 0,
    Suffix = " studs",
    Tooltip = "Maximum range to detect and revive teammates.",
})


local function _findGroundDetail2Target()
    -- 1. Try exact path provided by user
    local st = Workspace:FindFirstChild("Structures")
    local genF = st and st:FindFirstChild("Generator")
    local genM = genF and genF:FindFirstChild("GeneratorModel")
    
    -- 2. If not found via exact path, search entire workspace for "GeneratorModel"
    if not genM then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "GeneratorModel" then
                genM = obj
                break
            end
        end
    end
    
    -- 3. If still not found, fallback to old findGenerator
    if not genM then
        genM = _findGenerator and _findGenerator() or nil
    end
    
    -- Extract a valid BasePart to tween to
    if genM then
        -- Try to find GroundDetail2 inside it first (safest spot)
        local gd2 = genM:FindFirstChild("GroundDetail2", true)
        if gd2 and gd2:IsA("BasePart") then return gd2 end
        
        -- If no GroundDetail2, return the model itself or its primary part
        if genM:IsA("BasePart") then return genM end
        if genM:IsA("Model") and genM.PrimaryPart then return genM.PrimaryPart end
        
        -- Finally, just return any BasePart inside
        return genM:FindFirstChildWhichIsA("BasePart", true)
    end
    
    -- 4. Ultimate fallback: look for ANY GroundDetail2 in workspace
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "GroundDetail2" and obj:IsA("BasePart") then
            local d = hrp and (obj.Position - hrp.Position).Magnitude or 0
            if d < bestDist then
                best = obj
                bestDist = d
            end
        end
    end
    return best
end

local function _getGroundDetailStandPosition(part, hrp)
    local yOffset = 4
    if hrp and hrp:IsA("BasePart") then
        yOffset = math.max(4, hrp.Size.Y * 0.5 + 2)
    end
    return part.Position + Vector3.new(0, (part.Size.Y * 0.5) + yOffset, 0)
end

local function _hasClearSegment(fromPos, toPos, char)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { char }
    return Workspace:Raycast(fromPos, toPos - fromPos, rayParams) == nil
end

local function _tweenHRPTo(hrp, pos, speed)
    local char = hrp.Parent
    if not char then return false end
    
    local finalTarget = pos
    local FAST_SPEED = speed
    local SLOW_SPEED = 10
    local CLEARANCE_COOLDOWN = 0.5
    local lastWallDetectedTime = 0
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char}
    
    local isTweening = true
    local noclipConn = RunService.Stepped:Connect(function()
        if not isTweening then return end
        if char then
            for _, child in ipairs(char:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end)
    
    while true do
        if not hrp or not hrp.Parent then break end
        local currentPos = hrp.Position
        local remainingVector = finalTarget - currentPos
        local totalDistance = remainingVector.Magnitude
        
        if totalDistance <= 2 or totalDistance <= 0.25 then
            hrp.CFrame = CFrame.new(finalTarget)
            hrp.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            hrp.Anchored = true
            task.wait(0.05)
            hrp.Anchored = false
            break
        end
        
        local direction = remainingVector.Unit
        local lookAheadDistance = 5
        local rayResult = workspace:Raycast(currentPos, direction * lookAheadDistance, raycastParams)
        
        if rayResult and rayResult.Instance and rayResult.Instance.CanCollide then
            lastWallDetectedTime = os.clock()
        end
        
        local activeStepDistance = 0.25
        local currentAllowedSpeed = SLOW_SPEED
        
        if os.clock() - lastWallDetectedTime >= CLEARANCE_COOLDOWN then
            activeStepDistance = math.min(1.65, totalDistance)
            currentAllowedSpeed = FAST_SPEED
        end
        
        local delayInterval = activeStepDistance / currentAllowedSpeed
        local SoltPosition = currentPos + (direction * activeStepDistance)
        
        hrp.CFrame = CFrame.new(SoltPosition)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        task.wait(delayInterval)
    end
    
    isTweening = false
    noclipConn:Disconnect()
    return true
end

local function _smartTweenToGroundDetail(targetPart, attempt)
    attempt = attempt or 1
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hrp or not hum or not targetPart then return false end

    local targetPos = _getGroundDetailStandPosition(targetPart, hrp)
    local pathGoal = targetPart.Position + Vector3.new(0, targetPart.Size.Y * 0.5, 0)
    local speed = 30

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 5,
    })

    local ok = pcall(function()
        path:ComputeAsync(hrp.Position, pathGoal)
    end)

    if ok and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for i = 2, #waypoints do
            if not hrp.Parent then return false end
            local wp = waypoints[i]
            if wp.Action == Enum.PathWaypointAction.Jump then
                hum.Jump = true
            end

            local wpPos = wp.Position + Vector3.new(0, math.max(2.5, hrp.Size.Y * 0.5), 0)
            if not _hasClearSegment(hrp.Position, wpPos, char) then
                if attempt < 3 then
                    return _smartTweenToGroundDetail(targetPart, attempt + 1)
                end
                return false
            end
            _tweenHRPTo(hrp, wpPos, speed)
        end
        _tweenHRPTo(hrp, targetPos, speed)
        return true
    end

    if _hasClearSegment(hrp.Position, targetPos, char) then
        return _tweenHRPTo(hrp, targetPos, speed)
    end

    return false
end

local _cachedGeneratorVector3 = nil
local _cachedGeneratorPathGoal = nil

movementGroup:AddButton("Tween to Base/Generator", function()
    local target = _findGroundDetail2Target()
    
    -- Update cache if target is found
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if target and hrp then
        _cachedGeneratorVector3 = _getGroundDetailStandPosition(target, hrp)
        _cachedGeneratorPathGoal = target.Position + Vector3.new(0, target.Size.Y * 0.5, 0)
    end
    
    if not target and not _cachedGeneratorVector3 then
        Library:Notify({ Title = "Teleport", Description = "Generator is completely unloaded (too far). Walk closer once to save its location!", Time = 4 })
        return
    end

    Library:Notify({ Title = "Teleport", Description = "Pathing to Generator/Base...", Time = 2 })
    task.spawn(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local targetPos = _cachedGeneratorVector3
        local pathGoal = _cachedGeneratorPathGoal
        
        if target then
            local ok = _smartTweenToGroundDetail(target)
            if ok then
                Library:Notify({ Title = "Teleport", Description = "Arrived at Generator/Base", Time = 2 })
            else
                -- Force tween if blocked
                _tweenHRPTo(hrp, targetPos, 40)
                Library:Notify({ Title = "Teleport", Description = "Forced Tween (Path Blocked)", Time = 2 })
            end
        else
            -- Target is streamed out, force tween to cached vector3
            _tweenHRPTo(hrp, targetPos, 40)
            -- Wait a bit for the chunk to stream in, then anchor to prevent falling
            hrp.Anchored = true
            task.wait(1.5)
            hrp.Anchored = false
            Library:Notify({ Title = "Teleport", Description = "Arrived (Bypassed Unloaded Chunk)", Time = 2 })
        end
    end)
end)


end
_buildMiscTab()


-- ============================================
-- UNLOAD CLEANUP
-- [CHANGED] Cleans up all 6 category ESP systems
-- ============================================
Library:OnUnload(function()
    if stopAutoFarmGem then pcall(function() stopAutoFarmGem() end) end
    -- Clean up Mob ESP
    for char, _ in pairs(mobESPInstances) do
        removeMobESP(char)
    end

    -- Clean up all 6 category ESP systems
    for _, sys in pairs(espSystems) do
        for item, _ in pairs(sys.instances) do
            sys.remove(item)
        end
    end

    -- Clean up Player ESP
    for player, _ in pairs(playerESPInstances) do
        removePlayerESP(player)
    end

    -- Clean up Structure ESP
    for structure, _ in pairs(structureESPInstances) do
        removeStructureESP(structure)
    end

    -- Disconnect all connections with pcall safety
    for _, conn in ipairs(connections) do
        if typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    connections = {}

    -- Stop all active features
    stopAutoPickup()
    stopRepairAura()
    stopFly()
    stopAutoSprint()
    stopKillAura()
    stopSpeedHack()
    -- Clean up Silent Aim hook (restore original function to the game's _G)
    if getgenv()._NX_SilentAimOriginal then
        local g = getgenv()._NX_SilentAimGameG or _G
        g.getCurrentAutoTargetPosition = getgenv()._NX_SilentAimOriginal
        getgenv()._NX_SilentAimOriginal = nil
        getgenv()._NX_SilentAimGameG = nil
    end
    -- Clean up ManualAim override
    if getgenv()._NX_ManualAimConn then
        getgenv()._NX_ManualAimConn:Disconnect()
        getgenv()._NX_ManualAimConn = nil
    end
    -- Clean up AutoCombat loop
    if getgenv()._NX_AutoCombatConn then
        getgenv()._NX_AutoCombatConn:Disconnect()
        getgenv()._NX_AutoCombatConn = nil
    end
    stopBhop()        -- [ADDED v7.3] Clean up bunny hop on unload
    stopFunnyDance()  -- Clean up funny dance on unload
    stopRemoteSpy()   -- [ADDED v7.3] Clean up remote spy on unload
    -- [ADDED] Clean up new feature loops
    STA_E.stopHitbox()
    STA_E.stopSpinbot()
    STA_E.stopAutoUse()
    STA_E.stopAutoTrash()
    STA_E.stopAntiProximityPrompt()
    STA_E.stopAutoOpenChest()
    stopAutoFarmEngine()
    -- [ADDED v7.3.3] Restore FPS cap on unload
    pcall(function() if setfpscap then setfpscap(60) end end)
    pcall(function() RunService:UnbindFromRenderStep("SolanaHubAimLock") end)
    if _mobileAimBtnGui then pcall(function() _mobileAimBtnGui:Destroy() end); _mobileAimBtnGui = nil end
    -- [REMOVED v7.3.1] No Stamina Drain - game uses hunger, not stamina
    -- Restore Remove Fog
    if Toggles.RemoveFog and Toggles.RemoveFog.Value then
        disableRemoveFog()
    end

    -- Restore Speed Hack
    if Toggles.SpeedHack and Toggles.SpeedHack.Value then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = originalValues.walkSpeed or 16
            end
        end
    end

    -- Restore Fullbright
    if Toggles.Fullbright and Toggles.Fullbright.Value then
        disableFullbright()
    end

    -- Stop Anti-AFK
    stopAntiAFK()

    Library:Notify({ Title = "Solana Hub", Description = "Unloaded. Bye!", Time = 3 })
    print("SolanaHubSTA 1.7.9 unloaded.")
end)

-- ============================================
-- UI SETTINGS TAB
-- ============================================
local function _buildUISettingsTab()

MenuGroup = Tabs["UI Settings"]:AddCenterGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library:SetKeybindMenuVisible(value)
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library:SetCustomCursor(Value)
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})

MenuGroup:AddSlider("UICornerSlider", {
    Text = "Corner Radius",
    Default = Library.CornerRadius,
    Min = 0,
    Max = 20,
    Rounding = 0,
    Callback = function(value)
        Window:SetCornerRadius(value)
    end,
})

MenuGroup:AddDivider()

-- [LANGUAGE SWITCHER]
MenuGroup:AddDropdown("LanguageSetting", {
    Values = {
        "Indonesia (ID)",
        "English (EN)",
        "Espanol (ES)",
        "Portugues (PT)",
        "Melayu (MS)",
        "Filipino (TL)",
        "Deutsch (DE)",
        "Francais (FR)",
        "Arabic (AR)",
        "Tieng Viet (VI)",
        "Thai (TH)",
        "Turkce (TR)",
        "Japanese (JA)",
        "Korean (KO)",
        "Chinese (ZH)",
        "Russian (RU)",
    },
    Default = _LANG_LABELS[_LANG] or "English (EN)",
    Text = L.language,
    Tooltip = L.langApply,
    Callback = function(val)
        local code = val:match("%((%u%u)%)$") or "EN"
        local oldLang = _LANG
        local saved = pcall(function()
            local folder = "SolanaHub/survive-the-apocalypse"
            if not isfolder("SolanaHub") then makefolder("SolanaHub") end
            if not isfolder(folder) then makefolder(folder) end
            writefile(folder .. "/lang.json", HttpService:JSONEncode({ lang = code }))
        end)
        _LANG = code
        RefreshLanguageUI(oldLang, code)
        Library:Notify({
            Title = L.language,
            Description = saved and val or "Failed to save language config",
            Time = 4,
        })
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", {
        Default = _window.Keybind or "RightControl",
        NoUI = true,
        Text = "Menu keybind",
        Callback = function(value)
            if type(value) == "string" and value ~= "" and value ~= "None" and value ~= "nil" and value ~= "true" and value ~= "false" then
                _window.Keybind = value
                Library:_syncKeybindFrame()
            end
        end,
    })

end
_buildUISettingsTab()

Library.ToggleKeybind = Options.MenuKeybind
if Options.MenuKeybind and type(Options.MenuKeybind.Value) == "string" and Options.MenuKeybind.Value ~= "" and Options.MenuKeybind.Value ~= "None" and Options.MenuKeybind.Value ~= "true" and Options.MenuKeybind.Value ~= "false" then
    _window.Keybind = Options.MenuKeybind.Value
end

-- FIX & PATCH: ModernV2 Window restore bug
-- When hidden, ModernV2 sets Window.Root.Parent = nil. When restoring, Roblox TweenService
-- fails to animate instances parented to nil, preventing the UI from ever reappearing.
if _window and type(_window.ToggleInterface) == "function" then
    local _origToggleInterface = _window.ToggleInterface
    _window.ToggleInterface = function(self, ...)
        if _window.Destroyed then return end
        local isCurrentlyVisible = _window.Signal and _window.Signal:GetValue()
        if not isCurrentlyVisible then
            -- We are about to SHOW the window: reparent WindowFrame back into ScreenGui
            pcall(function()
                if _window.Root and ModernV2 and ModernV2.ScreenGui then
                    _window.Root.Parent = ModernV2.ScreenGui
                    _window.Root.Visible = true
                end
            end)
        end
        return _origToggleInterface(self, ...)
    end
end

-- ============================================
-- THEME & SAVE MANAGERS
-- ============================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("SolanaHubSTA")
SaveManager:SetFolder("SolanaHub/survive-the-apocalypse")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
-- SaveManager:LoadAutoloadConfig()

-- ============================================
-- INIT NOTIFICATION
-- ============================================
-- Startup popup disabled by request.
-- Library:Notify({ Title = "SolanaHubSTA 1.7.9", Description = "Loaded! Gun|Melee|Medical|Armor|Food|Resources\nRight Shift = toggle menu.", Time = 5 })

local espCounts = { Gun="Red", Melee="Orange", Medical="Green", Armor="Blue", Food="Lime", Resource="Silver" }
print("SolanaHub 1.7.9 loaded | " .. #itemNames .. " items tracked | Right Shift = menu")
for cat, col in pairs(espCounts) do
    print(string.format("  %s ESP (%s) - %d items", cat, col, #espSystems[cat].items))
end
