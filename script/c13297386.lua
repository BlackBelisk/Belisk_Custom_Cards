--Devastation, the Almighty Dragon
--Scripted by Belisk
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be removed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	c:RegisterEffect(e1)
	--Opponent cannot remove
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetTargetRange(0,1)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	c:RegisterEffect(e2)
	--Search Itself
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_DECK)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.ithcon)
	e3:SetTarget(s.ithtg)
	e3:SetOperation(s.ithpop)
	c:RegisterEffect(e3)
	--Search WB, BW & W
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48049769,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,id+1)
	e4:SetCost(s.athcost)
	e4:SetTarget(s.athtarget)
	e4:SetOperation(s.athoperation)
	c:RegisterEffect(e4)
	--Special Summon From GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(80208323,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,id+2)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	--Special Summon In Standby Phase
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetOperation(s.ssspope)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetRange(LOCATION_GRAVE)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetCountLimit(1,id+3)
	e7:SetCondition(s.ssspcon)
	e7:SetTarget(s.sssptg)
	e7:SetOperation(s.ssspop)
	e7:SetLabelObject(e6)
	c:RegisterEffect(e7)
	--Recover and Draw
	local e8=Effect.CreateEffect(c)
    e8:SetCategory(CATEGORY_TOHAND)
    e8:SetType(EFFECT_TYPE_IGNITION)
    e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCountLimit(1,id+4)
    e8:SetTarget(s.rdtg)
    e8:SetOperation(s.rdop)
    c:RegisterEffect(e8)
end
--e3 Functions
function s.ithfilter(c)
	return (c:IsRace(RACE_BEASTWARRIOR) or c:IsRace(RACE_WINDBEAST)) and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
end
function s.ithcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return eg:IsExists(s.ithfilter,1,nil)
end
function s.ithtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_DECK)
end
function s.ithpop(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsAbleToHand() then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    end
end
--e3 Functions
--e4 Functions
function s.athcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.athfilter(c)
	return (c:IsRace(RACE_BEASTWARRIOR) or c:IsRace(RACE_WINDBEAST)) and c:IsLevelAbove(4) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
function s.athfilter2(c)
	return c:IsRace(RACE_WYRM) and c:IsLevelAbove(8) and c:IsAbleToHand()
end
function s.athtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.athfilter,tp,LOCATION_DECK,0,2,nil) and Duel.IsExistingMatchingCard(s.athfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,3,tp,LOCATION_DECK)
end
function s.athoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.athfilter,tp,LOCATION_DECK,0,2,2,nil)
	if #g>1 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		local h=Duel.SelectMatchingCard(tp,s.athfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if #h>0 then
			Duel.SendtoHand(h,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,h)
		end
	end
end
--e4 Functions
--e5 Functions
function s.spfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.spfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.BreakEffect()
        Duel.Destroy(g,REASON_EFFECT)
	end
end
--e5 Functions
--e6 & e7 Functions
function s.ssspope(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if r & REASON_DESTROY==0 or r & REASON_EFFECT ==0 then return end
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
	end
end
function s.ssspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and c:GetFlagEffect(id)>0
end
function s.chlimit(e,tp,eg,ep,ev,re,r,rp,chk)
	return rp == tp 
end
function s.sssptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(id)
	Duel.SetChainLimit(s.chlimit)
end
function s.ssspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    	Duel.BreakEffect()
    	Duel.Destroy(g,REASON_EFFECT)
	end
end
--e6 & e7 Functions
--e8 Functions
function s.rdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.athfilter2(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.athfilter2,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local h=Duel.SelectTarget(tp,s.athfilter2,tp,LOCATION_GRAVE,0,1,1,nil)    
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,h,1,tp,LOCATION_GRAVE)
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
       		Duel.ShuffleHand(tp)
       		Duel.BreakEffect()
       		Duel.Draw(tp,1,REASON_EFFECT) 
    	end
    end
end
--e8 Functions