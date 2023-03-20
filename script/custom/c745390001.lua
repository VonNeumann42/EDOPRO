-- Flaring Light
-- Scripted by VonNeumann42

local s,id=GetID()
function s.initial_effect(c)
    --Ritual summon:
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp, chk)
    local pc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local pc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if pc1 and pc2 and pc1:IsFaceup() and pc2:IsFaceup() then
		local ls,rs=pc1:GetLeftScale(),pc2:GetRightScale()
        if ls == rs then
			if e:GetHandler():IsLocation(LOCATION_DECK) then e:SetLabel(1) else e:SetLabel(0) end
            return true
        end
    end 
    return false
end

function s.filter(c,e,tp)
	if c:IsRitualMonster() and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) 
        and c:GetLevel() == Duel.GetFieldCard(tp,LOCATION_PZONE,0):GetRightScale() and c:GetLevel() == Duel.GetFieldCard(tp,LOCATION_PZONE,1):GetLeftScale() and
		(Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 or not c:IsLocation(LOCATION_EXTRA)) then return true
	end
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then
		
		local sloc = e:GetLabel() == 1
		local fhd = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not sloc
			and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,nil)
		
		local fdk = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and sloc
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp,nil)

		return fhd or fdk
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local tg=nil
	if e:GetLabel() == 0 then
		tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	else
		tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	end

	local tc=tg:GetFirst()
	if tc then
		local loc = tc:IsLocation(LOCATION_DECK)
		tc:SetMaterial(nil)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		if loc or e:GetLabel() == 1 then 
			local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
			Duel.Destroy(dg, REASON_EFFECT)
		end
	end
end
