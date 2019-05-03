--Inanis Belua
--Designed and Scripted by Belisk
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x369),4,2)
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
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
end
function s.shcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.filter(c)
	return c:IsSetCard(0x369) and c:IsAbleToDeck() and 
	(c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATODECK)
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
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
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0x369) and c:IsAbleToHand()
end
function s.tgchk1(c)
	return c:IsOnField()
end
function s.tgchk2(c,tp)
	return (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) and c:IsControler(tp) and s.thfilter(c)
end
function s.tgcon1(e,tp,eg,ep,ev,re,r,chk,chkc)
	return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.tgchk1(chkc) or s.tgchk2(chkc,tp) end
	local destroy = s.tgcon1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tohand = s.tgcon2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk == 0 then return destroy or tohand end
	local tg
	local op
	if destroy and tohand then
		op = Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif destroy then op = 0
	elseif negate then op = 1
	else return end 
	if op == 0 then
		e:SetCategory(CATEGORY_DESTROY) 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		tg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
		e:SetOperation(s.op1)
	elseif op == 1 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		tg = Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,0,0)
		e:SetOperation(s.op2)
	else return end 
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
