--Inanis Praetor
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon
	aux.EnablePendulumAttribute(c)
	--Special Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.psplimit)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.stcon)
	e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)
end
function s.psplimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x369) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.stcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x369)
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,1022019+1,0,TYPES_TOKEN,0,0,1,RACE_SPELLCASTER,ATTRIBUTE_EARTH) end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #dg<2 then return end
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	local ct=4
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,1022019+1,0,TYPES_TOKEN,0,0,1,RACE_SPELLCASTER,ATTRIBUTE_EARTH) then return end
	local ct=math.min(ct,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ct<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	repeat
		local token=Duel.CreateToken(tp,1022019+1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		ct=ct-1
	until ct<=0 or not Duel.SelectYesNo(tp,aux.Stringid(94703021,0))
	Duel.SpecialSummonComplete()
end
--Here should to go the Special Summon Effect but I don't know how to do it xDDDDDD