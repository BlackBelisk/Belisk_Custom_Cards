--Inanis Dux
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	c:RegisterEffect(e1)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thcon(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.IsPlayerAffectedByEffect(tp,2032019) 
end
function s.filter1(c)
 	return c:IsCode(11022019) and c:IsAbleToHand()
 end
function s.filter2(c)
 	return c:IsCode(12022019) and c:IsAbleToHand()
 end
function s.filter3(c)
	return c:IsCode(12032019) and c:IsAbleToHand()
end
function s.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end
function s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) 
		and  Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local praetor = s.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	local ludex = s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	local tg
	if chk==0 then return praetor or ludex end
	local op = 0
	if praetor and ludex then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif praetor then op = 0
	elseif ludex then op = 1
	else return end
	if op == 0 then
		e:SetOperation(s.thop1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	elseif op == 1 then
		e:SetOperation(s.thop2)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
	else return end
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg = Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local ludex = s.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	if ludex then 
		local g = Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			local h = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter3),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,g:GetFirst())
			if #h>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local hg = h:Select(tp,1,1,nil)
				g:Merge(hg)
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
