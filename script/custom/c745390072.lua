-- BattleShip Flak Battery
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Weaken Destroy and Burn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end

s.listed_series={0x0227}

-- e2 functions

function s.filter(c)
	return c:IsFaceup()
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter, tp, 0, LOCATION_MZONE, nil)
	if #g==0 then 
		Duel.Damage(1-tp, 600, REASON_EFFECT) 
		return
	end
	local dg=Group.CreateGroup()
	local c=e:GetHandler()
	for tc in g:Iter() do
		local ei1=Effect.CreateEffect(c)
		ei1:SetType(EFFECT_TYPE_SINGLE)
		ei1:SetCode(EFFECT_UPDATE_ATTACK)
		ei1:SetValue(-600)
		ei1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ei1)
		if tc:GetAttack()==0 then dg:AddCard(tc) end
	end
	if #dg==0 then 
		Duel.Damage(1-tp, 600, REASON_EFFECT)
	else
		Duel.BreakEffect()
		if Duel.Destroy(dg,REASON_EFFECT) == 0 then
			Duel.Damage(1-tp, 600, REASON_EFFECT)
		end
	end
end