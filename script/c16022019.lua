--Inanis Rex
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon & Pendulum Attribute
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x369),2)
	aux.EnablePendulumAttribute(c,false)
	--Special Summon from ED
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.hspcon)
    e1:SetOperation(s.hspop)
    c:RegisterEffect(e1)
	--Special Summon Limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.psplimit)
	c:RegisterEffect(e2)
	--Special Summon From Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--Shuffle into the deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(15022019,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+2)
	e4:SetCondition(s.shcon)
	e4:SetTarget(s.shtg)
	e4:SetOperation(s.stactivate)
	c:RegisterEffect(e4)
	--Cannot Be Destroyed
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(s.indcon)
	e5:SetTarget(s.indtg)
	e5:SetValue(s.indval)
	c:RegisterEffect(e5)
	--Cannot Be Targeted
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetValue(aux.tgoval)
	c:RegisterEffect(e6)
	--Place in Pendulum Zone
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(100219001,3))
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCondition(s.pencon)
	e8:SetTarget(s.pentg)
	e8:SetOperation(s.penop)
	c:RegisterEffect(e8)
end
function s.cfilter22(c)
    return (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsAbleToRemoveAsCost() 
        and (c:IsLocation(LOCATION_HAND+LOCATION_SZONE) or aux.SpElimFilter(c,true,true))
end
function s.sprfilter1(c,mg)
    local mg2=mg:Clone()
    mg2:RemoveCard(c)
    return c:IsCode(13022019) and mg2:IsExists(s.sprfilter2,1,nil,mg2)
end
function s.sprfilter2(c,mg)
    local mg2=mg:Clone()
    mg2:RemoveCard(c)
    return c:IsCode(14022019)
end
function s.hspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local mg=Duel.GetMatchingGroup(s.cfilter22,tp,LOCATION_GRAVE,0,nil)
    return mg:IsExists(s.sprfilter1,1,nil,mg,ft)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
    local mg=Duel.GetMatchingGroup(s.cfilter22,tp,LOCATION_GRAVE,0,nil)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g1=mg:FilterSelect(tp,s.sprfilter1,1,1,nil,mg,ft)
    local tc1=g1:GetFirst()
    mg:RemoveCard(tc1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g2=mg:FilterSelect(tp,s.sprfilter2,1,1,nil,mg,ft)
    local tc2=g2:GetFirst()
    mg:RemoveCard(tc2)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    g1:Merge(g2)
    Duel.Remove(g1,POS_FACEUP,REASON_COST)
end

function s.psplimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x369) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x369)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.shcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.filter(c)
	return c:IsSetCard(0x369) and c:IsAbleToDeck()
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATODECK)
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,3,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.stactivate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)==0 then return end
	if Duel.SendtoDeck(tg,nil,3,REASON_EFFECT)~=0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(3032019,1)) then
		local shg = Duel.GetOperatedGroup()
		if shg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.ShuffleHand(tp)
	end
end

function s.indcon(e,c)
	local lk = e:GetHandler():GetMutualLinkedGroup()
	return lk:IsExists(Card.IsCode,1,nil,15022019)
end
function s.indtg(e,c)
	return c==e:GetHandler() or (c:GetMutualLinkedGroup():IsContains(e:GetHandler()) and c:IsCode(15022019))
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.pencon(e,tp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup() and (Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.IsPlayerAffectedByEffect(tp,3032019))
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
