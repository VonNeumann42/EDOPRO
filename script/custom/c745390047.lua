-- The Land of Perpetual Rust
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Reduce Stats
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DETACH_MATERIAL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_LOST_TARGET==0 end)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- Attach
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.ovcon)
	e3:SetTarget(s.ovtg)
	e3:SetOperation(s.ovop)
	c:RegisterEffect(e3)
end

s.listed_series={0x0226}

function s.ovcfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsSetCard(0x0226)
end

function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ovcfilter,1,nil,tp)
end

function s.ovfilter(c)
	return c:IsSetCard(0x0226)
end

function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.ovfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil) end

end

function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local sc = eg:GetFirst()
	local selc = Duel.SelectMatchingCard(tp, s.ovfilter, tp, LOCATION_GRAVE+LOCATION_HAND, 0, 1, 1, nil)
	Duel.Overlay(sc, selc)
end

-- e2

function s.filter(c)
	return not (c:IsSetCard(0x0226) and c:IsType(TYPE_XYZ))
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-350)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(-350)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
