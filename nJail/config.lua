Config = {}

Config.InitESX = "esx:getSharedObject" -- ESX Init

Config.jailCMD = "jail" -- Command to jail a player 
Config.jailPannel = "jailpannel" -- Command to unjail a player

Config.allowedRank = { -- Allowed ranks to jail/unjail players
    "user",
    "mod",
    "admin",
    "superadmin",
    "_dev",
}

Config.JailPos = vector3(1641.6, 2571.0, 45.5) -- Jail position
Config.UnjailPos = vector3(1846.03, 2585.86, 45.67) -- Unjail position

Config.LogsLink = "https://discord.com/api/webhooks/1078966898940719124/CBMcju9YeW5Ssc0rt7XARjhF54zMBg0Gov2VI7uvWUSXRGSq_k8TtAQjssTXwM4QQ4Ta" -- Logs webhook link