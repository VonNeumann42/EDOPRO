-- BattleShip Fighter Wing
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	-- Protect from Destruction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- Halve Battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
	c:RegisterEffect(e2)
end

-- e1 functions

function s.desfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) and 
		not c:IsReason(REASON_REPLACE) and c:IsControler(tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c = e:GetHandler()
	if chk==0 then return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) and 
		not c:IsReason(REASON_REPLACE) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
end
