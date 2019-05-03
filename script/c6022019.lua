--Entity Of Greed
--Scripted by Belisk
local s,id=GetID()
function s.initial_effect(c)
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
	--Draw from Pendulum Zone
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,3022019)
	e2:SetCondition(s.dpzcon)
	e2:SetTarget(s.dpztg)
	e2:SetOperation(s.dpzop)
	c:RegisterEffect(e2)
	--Draw by Discard
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,3022019+1)
	e3:SetCondition(s.dcon)
	e3:SetCost(s.dcost)
	e3:SetTarget(s.dtg)
	e3:SetOperation(s.dop)
	c:RegisterEffect(e3)
end
function s.psplimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x369) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.dpzcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x369)
end
function s.dpztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.dpzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local dg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if #dg<2 then return end
	if Duel.Destroy(dg,REASON_EFFECT)~=2 then return end
	local p,d = Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.BreakEffect()
	Duel.Draw(p,d,REASON_EFFECT)
end

function s.dcon(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 or Duel.IsPlayerAffectedByEffect(tp,2032019)
end

function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c = e:GetHandler()
	if chk == 0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.dop(e,tp,eg,ep,ev,re,r,rp,chk)
	local p,d = Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end