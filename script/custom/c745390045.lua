-- Perpetual Cooling System
-- Scripted by VonNeumann42
-- 0226
local s,id=GetID()
function s.initial_effect(c)
	--Special summon when detached
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.sscon)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	-- Quick XYZ
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,{id,3})
	e4:SetCost(s.discost)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end

s.listed_names={id}
s.listed_series={0x0226}

-- e1 functions

function s.ssfilter(c)
	return c:IsSetCard(0x0226) and c:IsType(TYPE_XYZ)
end

function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_OVERLAY) and Duel.IsExistingMatchingCard(s.ssfilter, tp, LOCATION_ONFIELD, 0, 1, nil) and 
		c:IsLocation(LOCATION_GRAVE)
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

-- e4 functions

function s.disfilter(c)
	return c:IsXyzSummonable() and c:IsRace(RACE_MACHINE)
end

function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.disfilter, tp, LOCATION_EXTRA, 0, nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp, sg:GetFirst())
	end
end