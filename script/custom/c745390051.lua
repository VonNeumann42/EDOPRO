-- Perpetual Decay
-- Scripted by VonNeumann42

local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- Recur
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.retg)
	e2:SetOperation(s.reop)
	c:RegisterEffect(e2)
end
s.listed_series={0x0226}

function s.filter(c)
	return c:IsSetCard(0x0226) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		local tc=sg:RandomSelect(1-tp,1):GetFirst()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		sg:RemoveCard(tc)
		Duel.Remove(sg, POS_FACEUP, REASON_EFFECT)
	end
end

-- e2 functions

function s.retg(e, tp, eg, ep, ev, re, r, rp, chk)
	local g=Duel.GetDecktopGroup(tp,1)
	local c = e:GetHandler()
	if chk==0 then return g:FilterCount(Card.IsAbleToRemove,nil,tp,POS_FACEUP)==1 and c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND, c, 1, tp, LOCATION_GRAVE)
end

function s.reop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetDecktopGroup(tp,1)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local rg=Duel.GetOperatedGroup()
	local tc=rg:GetFirst()
	if tc:IsLocation(LOCATION_REMOVED) and tc:IsSetCard(0x0226) and c:IsAbleToHand() then
		Duel.BreakEffect()
		Duel.SendtoHand(c, tp, REASON_EFFECT)
	end
end
