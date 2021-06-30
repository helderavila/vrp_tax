local lang = vRP.lang
local Luang = module("vrp", "lib/Luang")

local vrpTax = class("vrpTax", vRP.Extension)

function vrpTax:__construct()
	vRP.Extension.__construct(self)

	self.cfg = module("vrp_tax", "cfg/tax")

	self.luang = Luang()
	self.luang:loadLocale(vRP.cfg.lang, module("vrp_tax", "cfg/lang/"..vRP.cfg.lang))
	self.lang = self.luang.lang[vRP.cfg.lang]

	local function initCharge()
		SetTimeout(60000*self.cfg.minutes,initCharge)
		self:chargeTax()
	end
	async(function()
		initCharge()
	end)
end

function vrpTax:chargeTax()
	for perm,tax in pairs(self.cfg.tax) do
		local users = vRP.EXT.Group:getUsersByGroup(perm)
		for _,user in pairs(users) do
			local userBankMoney = user:getBank()
			if tax < userBankMoney then
				user:tryFullPayment(tax)
				vRP.EXT.Base.remote._notify(user.source,self.lang.money.tax({tax}))
			else
				vRP.EXT.Base.remote._notify(user.source, self.lang.money.withoutMoney())
			end
		end
	end
end

vRP:registerExtension(vrpTax)