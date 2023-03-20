-- Arcane Spark
-- Scripted by VonNeumann42

local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Summon Rules:
	c:EnableReviveLimit()
    -- Place in scale
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,1})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTarget(s.actar)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- Negate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.negconm)
	e2:SetTarget(s.negtar)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e2:SetCountLimit(1,{id,3})
	e3:SetCondition(s.negcons)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e2:SetCountLimit(1,{id,4})
	e4:SetCondition(s.negcont)
	c:RegisterEffect(e4)
	-- Change scale
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetRange(LOCATION_PZONE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_CHANGE_LSCALE)
	e4:SetCondition(s.sccon)
	e5:SetValue(s.scvall)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CHANGE_RSCALE)
	e6:SetValue(s.scvalr)
	c:RegisterEffect(e6)

end

-- e1 functions:

function s.acfilter(c)
	return c:IsCode(id)
end

function s.actar(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then 
		return Duel.GetMatchingGroupCount(nil,tp,LOCATION_PZONE,0,nil)==1 and
		Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
	end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end

function s.acop(e, tp, eg, ep, ev, re, r, rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

-- e2-4 functions:

function s.negconm(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and ep~=tp
end

function s.negcons(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev) and ep~=tp
end

function s.negcont(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
		and re:IsActiveType(TYPE_TRAP) and Duel.IsChainNegatable(ev) and ep~=tp
end

function s.desfilter(c)
	return c:IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.negtar(e, tp, eg, ep, ev, re, r, rp, chk)
	if chkc then return chkc:IsControler(tp) and chkc:IsSummonType(SUMMON_TYPE_RITUAL) end
	if chk == 0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.NegateActivation(ev)
	end
end

-- e5-6 functions

function s.scfilter(c,e)
	return c:IsFaceup() and not c:IsHasEffect(id) 
	and (c:GetLeftScale() ~= e:GetHandler():GetOriginalLeftScale()
	or c:GetRightScale() ~= e:GetHandler():GetOriginalRightScale())
end

function s.sccon(e)
	return Duel.GetMatchingGroupCount(s.scfilter, e:GetHandlerPlayer(), LOCATION_PZONE, 0, e:GetHandler(),e) > 0
end

function s.scvall(e,c)
	local g=Duel.GetMatchingGroup(s.scfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,e:GetHandler(),e)
	if #g==0 then return c:GetOriginalLeftScale() end
	local scc=g:GetFirst()
	return scc:GetLeftScale()
	
end

function s.scvalr(e,c)
	local g=Duel.GetMatchingGroup(s.scfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,e:GetHandler(),e)
	if #g==0 then return c:GetOriginalLeftScale() end
	local scc=g:GetFirst()
	return scc:GetRightScale()
end
