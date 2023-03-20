-- BattleShip Cannon Battery
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Destroy or burn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end

s.listed_series={0x0227}

-- e2 functions

function s.filter(c,tp)
	return c:IsControler(1-tp) and c:IsFaceup()
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	
	local g=c:GetColumnGroup(1,1)
	g=g:Filter(s.filter, nil, tp)

	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		if Duel.Destroy(sg,POS_FACEUP,REASON_EFFECT) == 0 then 
			Duel.Damage(1-tp,600,REASON_EFFECT)
		end
	else
		Duel.Damage(1-tp,600,REASON_EFFECT)
	end

end