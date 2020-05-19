trigger DeDupe on Account (after insert) {
    for (Account acct: Trigger.new) {
	case c = new Case();
		c.subject = 'Dedupe this account'; 
        c.Ownerid = '00544000009UPMY';
  		c.AccountId = acct.Id;
        insert c;
        }
}