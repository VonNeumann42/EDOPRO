-- Perpetual Gearwheel
-- Scripted by VonNeumann42
-- 0226
local s,id=GetID()
function s.initial_effect(c)
	--Special summon when detached
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.sscon)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	--special summon on summon (From Hand)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.sotg)
	e2:SetOperation(s.soop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	
end

s.listed_names={id}
s.listed_series={0x0226}

-- e1 functions

function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_OVERLAY) and c:IsLocation(LOCATION_GRAVE)
end

function s.sstg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.ssop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		-- Cannot summon except perpetuals
		local ei1=Effect.CreateEffect(e:GetHandler())
		ei1:SetDescription(aux.Stringid(id,2))
		ei1:SetType(EFFECT_TYPE_FIELD)
		ei1:SetRange(LOCATION_MZONE)
		ei1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		ei1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		ei1:SetAbsoluteRange(tp,1,0)
		ei1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ei1:SetTarget(function(_,c) return not c:IsSetCard(0x0226) end)
		c:RegisterEffect(ei1)
	end
end

-- e2 functions

function s.sofilter(c,e,tp)
	return c:IsSetCard(0x0226) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end

function s.sotg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sofilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.soop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sofilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		tc=g:GetFirst()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local ei2=Effect.CreateEffect(e:GetHandler())
		ei2:SetDescription(3302)
		ei2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		ei2:SetType(EFFECT_TYPE_SINGLE)
		ei2:SetCode(EFFECT_CANNOT_TRIGGER)
		ei2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(ei2)
	end
end