-- Closed Room of the Eyeless
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- Cannot flip summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.changetg)
	e2:SetCondition(s.changecon)
	c:RegisterEffect(e2)
	-- Indestructible
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(_,c) return c:IsPosition(POS_FACEDOWN_DEFENSE) end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- Fusion Summon
	local params = {fusfilter=s.fusfilter,matfilter=s.matfil,stage2=s.stage2}
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(Fusion.SummonEffTG(params))
	e4:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e4)
end

-- e2 functions

function s.changecon(e)
	return Duel.GetCurrentPhase() ~= PHASE_MAIN2
end
function s.changetg(e,c)
	return c:IsFacedown()
end

-- e4 functions

function s.fusfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(556)
end

function s.matfil(c)
	return not c:IsLocation(LOCATION_HAND)
end

function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			local ei2=Effect.CreateEffect(c)
			ei2:SetDescription(aux.Stringid(id,1))
			ei2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			ei2:SetType(EFFECT_TYPE_SINGLE)
			ei2:SetCode(EFFECT_CANNOT_TRIGGER)
			ei2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
			c:RegisterEffect(ei2)
		end
	end
end
