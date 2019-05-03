--Inanis Daemonius
--Designed and Scripted by Belisk
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.condition(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.IsPlayerAffectedByEffect(tp,2032019)
end
function s.filter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil,e,tp) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		or not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,nil,e,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
	if #g==2 then 
    	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end