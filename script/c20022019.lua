--Inanis Tyrannus
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,18022019,19022019)
	aux.AddContactFusion(c,s.contactfil,s.contactop,s.splimit)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--Avoid Damage
	local e3=e2:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
	--Equip or Copy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.condition)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),s.eqop,e4)
	c:RegisterEffect(e4)
end
s.material_setcode=0x369
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.condition(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==1 or Duel.IsPlayerAffectedByEffect(tp,3032019)
end
function s.costcondition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) 
end
function s.costfilter2(c,ec)
	return c:GetFlagEffect(id)~=0 and c:GetEquipTarget()==ec and c:GetOriginalType()&TYPE_MONSTER~=0
end
function s.costcondition2(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	return Duel.IsExistingTarget(s.costfilter2,tp,LOCATION_SZONE,0,1,nil,c)
end
function s.costconditiontarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c = e:GetHandler()
	return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.costfilter2(chkc,c)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c = e:GetHandler()
	local discard = s.costcondition1(e,tp,eg,ep,ev,re,r,rp)
	local equipdestroy = s.costcondition2(e,tp,eg,ep,ev,re,r,rp)
	if chkc then return s.costconditiontarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then return discard or equipdestroy end
	local op 
	if discard and equipdestroy then
		op = Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif discard then op = 0
	elseif equipdestroy then op = 1
	else return end
	if op == 0 then
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	elseif op == 1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local tg = Duel.SelectTarget(tp,s.costfilter2,tp,LOCATION_SZONE,0,1,1,nil,c)
		Duel.Destroy(tg,REASON_EFFECT)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
	end
end
function s.eqfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
function s.econ1(c,tp)
	return c:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc,tp)
end
function s.econ2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp,chkc) 
end
function s.copyfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.copycon1(c,tp)
	return c:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.copyfilter(chkc)
end
function s.copycon2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c = e:GetHandler()
	if chkc then return (s.econ1(chkc,tp) and chkc~=c) or (c2002109.copycon1() and chkc~=c) end
	local equip = s.econ2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local copy = s.copycon2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg
	if chk == 0 then return equip or copy end
	local op 
	if equip and copy then
		op = Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	elseif equip then op = 0
	elseif copy then op = 1
	else return end
	if op == 0 then
		e:SetCategory(CATEGORY_EQUIP)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		tg = Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp,chkc)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,tg,1,0,0)
		e:SetOperation(s.op1)
	elseif op == 1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,c)
		e:SetOperation(s.op2)
	else return end
end
function s.eqop(c,e,tp,tc)
	local atk = tc:GetTextAttack()
	if atk < 0 then atk = 0 end
	if not aux.EquipByEffectAndLimitRegister(c,e,tp,tc,id,true) then return end
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	tc:RegisterEffect(e2)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc or not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT)) then return end
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		s.eqop(c,e,tp,tc)
	else Duel.SendtoGrave(tc,REASON_EFFECT) end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsFaceup() or tc:IsLocation(LOCATION_GRAVE)) then
		local code=tc:GetOriginalCodeRule()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(43387895,1))
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_PHASE+PHASE_END)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e3:SetCountLimit(1)
			e3:SetRange(LOCATION_MZONE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetLabelObject(e1)
			e3:SetLabel(cid)
			e3:SetOperation(s.rstop)
			c:RegisterEffect(e3)
		end
	end
end
function s.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then c:ResetEffect(cid,RESET_COPY) end
	local e1=e:GetLabelObject()
	e1:Reset()
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end