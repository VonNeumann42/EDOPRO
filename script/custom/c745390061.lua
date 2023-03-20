-- BattleShip Boarding Pod
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	-- Steal card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.stcon)
	e1:SetTarget(s.sttg)
	e1:SetOperation(s.stop)
	c:RegisterEffect(e1)
end

-- e1 functions

function s.stcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end

function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c = e:GetHandler()
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.stop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
	if #g == 0 then return end
	sg=g:RandomSelect(tp,1)
	Duel.SendtoHand(sg,tp,REASON_EFFECT)
	Duel.ConfirmCards(tp,sg)
	Duel.ShuffleHand(tp)
	Duel.ShuffleHand(1-tp)
end