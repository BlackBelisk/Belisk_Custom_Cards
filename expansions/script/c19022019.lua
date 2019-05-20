--Inanis Usurpatore
--Designed and Scripted by Belisk
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x369),1,1,aux.NonTuner(nil),1,99)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.shcon)
	e1:SetTarget(s.shtg)
	e1:SetOperation(s.stactivate)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	-- e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	-- e2:SetOperation(c18022019.operation)
	c:RegisterEffect(e2)
end
function s.shcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.filter(c)
	return (c:IsSetCard(0x369) and c:IsAbleToDeck() and c:IsLocation(LOCATION_GRAVE)) 
		or (c:IsSetCard(0x369) and c:IsAbleToDeck() and c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c18022019.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATODECK)
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,3,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.stactivate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)==0 then return end
	if Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)~=0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(3032019,1)) then
		local shg = Duel.GetOperatedGroup()
		if shg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.ShuffleHand(tp)
	end
end
function s.condition(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==1 or Duel.IsPlayerAffectedByEffect(tp,3032019)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.tgcon1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,chkc) 
end
function s.thfilter(chkc)
	return (chkc:IsSetCard(0x369) and chkc:IsType(TYPE_PENDULUM) and chkc:IsAbleToHand() and chkc:IsLocation(LOCATION_DECK)) 
		or (chkc:IsSetCard(0x369) and chkc:IsType(TYPE_PENDULUM) and chkc:IsAbleToHand() and chkc:IsFaceup() and chkc:IsLocation(LOCATION_EXTRA))
end
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,chkc)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local shuffletd = s.tgcon1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local addth = s.tgcon2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg
	if chk == 0 then return shuffletd or addth end
	local op
	if shuffletd and addth then
		op = Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif shuffletd then op = 0
	elseif addth then op = 1
	else return end 
	if op == 0 then
		e:SetCategory(CATEGORY_TODECK) 
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_ONFIELD)
		e:SetOperation(s.op1)
	elseif op == 1 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
		e:SetOperation(s.op2)
	else return end 
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end