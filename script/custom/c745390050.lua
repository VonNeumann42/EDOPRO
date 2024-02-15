-- Perpetual Moribund
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false,s.xyzcheck)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	-- Unaffected on summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- Return to attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(2,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.tetg)
	e2:SetOperation(s.teop)
	c:RegisterEffect(e2)
end

s.listed_series={0x0226}


function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsSetCard(0x0226,xyz,sumtype,tp) and not c:IsCode(id)
end

function s.xyzcheck(g,tp,xyz)
	local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
	return mg:GetClassCount(Card.GetRank)==1
end

-- e1 functions 

function s.efilter(e,re)
	return re:GetOwner()~=e:GetOwner()
end

-- e2 functions

function s.tefilter(c,tp)
	return c:GetOwner()==tp and c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end

function s.olfilter(c)
	return c:IsSetCard(0x0226) and c:IsMonster()
end

function s.thfilter(c)
	return c:IsAbleToHand()
end

function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetOverlayGroup():IsExists(s.tefilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.olfilter, tp, LOCATION_MZONE+LOCATION_GRAVE, 0, 1, c) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_OVERLAY)
end

function s.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=c:GetOverlayGroup():FilterSelect(tp,s.tefilter,1,1,nil,tp):GetFirst()
	if not tc or Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)<1 or not tc:IsLocation(LOCATION_EXTRA) then return end
	
	local sc=Duel.SelectMatchingCard(tp, s.olfilter,tp, LOCATION_MZONE+LOCATION_GRAVE, 0, 1, 1, c)
	Duel.Overlay(c, sc, true)
	if sc:GetFirst():IsLocation(LOCATION_OVERLAY) and sc:GetFirst():IsType(TYPE_XYZ) then
		if Duel.SelectYesNo(tp, aux.Stringid(id,1)) then
			local bc = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, LOCATION_ONFIELD+LOCATION_GRAVE, 1, 1, nil)
			Duel.SendtoHand(bc, nil, REASON_EFFECT)
		end
	end
end