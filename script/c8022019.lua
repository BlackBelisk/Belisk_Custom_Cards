--Inanis Scurra
--Designed and Scripted by Belisk
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
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
	--Special Summon From Pendulum Zone
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--synchro limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(s.synlimit)
	c:RegisterEffect(e3)
	--Change on field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,id+1)
	e4:SetCondition(s.condition)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	c:RegisterEffect(e4)
	--[[local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(88581108,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,4022019+1)
	-- e4:SetCondition(s.condition)
	e4:SetCost(s.lvlcost)
	e4:SetTarget(s.lvltg)
	e4:SetOperation(s.lvlop)
	c:RegisterEffect(e4)--]]

end
function s.psplimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x369) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x369)
end
function s.tnfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x369) and not c:IsType(TYPE_TUNER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tnfilter(chkc) end
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,nil)
	if chk==0 then return Duel.IsExistingTarget(s.tnfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	if not c:IsRelateToEffect(e) then return end
	if tc and Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.tnfilter,tp,LOCATION_MZONE,0,1,1,nil)
		local tct=Duel.GetFirstTarget()
		if tct:IsRelateToEffect(e) and tct:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tct:RegisterEffect(e1)
		end
	end
end
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x369)
end
function s.condition(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.IsPlayerAffectedByEffect(tp,2032019)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return  Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	if op==0 then
		e:SetOperation(s.cop1)
	elseif op==1 then
		e:SetOperation(s.cop2)
	elseif op == 2 then
		e:SetOperation(s.cop3)
	end
end
function s.cop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,8)
	e:SetLabel(lv)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.cop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local rc=Duel.AnnounceAttribute(tp,1,0xffff)
	e:SetLabel(rc)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.cop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rc)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
