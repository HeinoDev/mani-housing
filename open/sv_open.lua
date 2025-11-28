local Util = {}

local Webhook = ''

function Util.AddMoneyForJob(Job, Amount)
    
end

function Util.Log(Source, Message)
    exports['mani-bridge']:DiscordWebhook(Source, {
        Webhook = Webhook,
        Resource = 'Mani-Housing',
        Message = Message
    })
end

return Util