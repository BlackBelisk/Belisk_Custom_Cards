--Inanis Atrium
--Designed and Scripted by Belisk
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Allow Activation Of Monster in Field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--Add to Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.atdcon)
	e3:SetTarget(s.tdtarget)
	e3:SetOperation(s.tdactivate)
	c:RegisterEffect(e3)
end
--e1 Functions
function s.condition(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.IsPlayerAffectedByEffect(tp,1032019)
end
--e1 Functions
--e2 Functions
function s.atdfilter(c)
	return c:IsSetCard(0x369) and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.atdfilter(chkc) end
	if chk==0 then return true end
	if Duel.IsExistingTarget(s.atdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetCategory(CATEGORY_TODECK)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.activate)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATODECK)
		local g=Duel.SelectTarget(tp,s.atdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)==0 then return end
	Duel.SendtoDeck(tg,nil,3,REASON_EFFECT)
end
--e2 Functions
--e3 Functions
function s.atdcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT)==REASON_EFFECT and e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
function s.atdfilter2(c)
	return c:IsSetCard(0x369) and c:IsAbleToDeck() 
end
function s.tdtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.atdfilter2(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) 
		and Duel.IsExistingTarget(s.atdfilter2,tp,LOCATION_GRAVE,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATODECK)
		local g=Duel.SelectTarget(tp,s.atdfilter2,tp,LOCATION_GRAVE,0,1,3,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.tdactivate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)==0 then return end
	if Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)~=0 and Duel.IsPlayerCanDraw(tp,1) then
		local shg = Duel.GetOperatedGroup()
		if shg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
       	Duel.ShuffleHand(tp)
       	Duel.BreakEffect()
       	Duel.Draw(tp,1,REASON_EFFECT) 
    end
end
--e3 Functions
