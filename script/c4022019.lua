--Inanis Destroyer
--Scripted by Belisk
local s,id=GetID()
function s.initial_effect(c)
	--Destroy or Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,0x1e0)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	c:RegisterEffect(e1)
end
--Condition e1
function s.condition(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.IsPlayerAffectedByEffect(tp,2032019)
end
--Condition e1
--Cost e1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.filter2(c)
	return c:IsFaceup() and not c:IsDisabled() and c:IsType(TYPE_EFFECT)  
end
function s.tgcon1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

function s.tgcon2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	return Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,chkc)
end

function s.tgchk1(c)
	return c:IsOnField()
end
function s.tgchk2(c,tp)
	return c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE) and s.filter2(c)
end
--Target
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.tgchk1(chkc) or s.tgchk2(chkc,tp) end
	local destroy=s.tgcon1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local negate=s.tgcon2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return destroy or negate end
	local tg
	local op
	if destroy and negate then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif destroy then op=0
	elseif negate then op=1
	else return end
	if op==0 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		tg=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
		e:SetOperation(s.op1)
	elseif op==1 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		tg=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,tp)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg,1,0,0)
		e:SetOperation(s.op2)
	else return end
end
--Operation e1
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT) 
		end
	end
end
--Operation e1
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and not tc:IsDisabled() and tc:IsControler(1-tp) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end