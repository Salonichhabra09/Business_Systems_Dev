({
    doInit : function(component, event, helper) {
                var result = new Date("Apr 5, 2021").getTime();
                console.log('Result : ' +result);
                var oppCloseDt = new Date(result);                
                var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
				var monthName = months[oppCloseDt.getMonth()];
                var dateNumber = oppCloseDt.getDate();
                var yearNumber =  oppCloseDt.getFullYear();
                console.log('Month Name: ' +monthName+' Date: '+dateNumber+' Year: '+yearNumber);
                var closeDateVar = monthName+' '+dateNumber+' '+yearNumber;
                var opptyCloseDate = new Date( closeDateVar+" 12:30:00 ");
                var now_date = new Date();
                //console.log('Todays date: ' +now_date);
                var timeDiff = opptyCloseDate.getTime()- now_date.getTime();
                	if(timeDiff<=0){
                    component.set("v.isValid",false);
                    component.set("v.msg",'Close Date Expired');
                 }else{
                     helper.countDownAction(component, event, helper, closeDateVar);
                 }
            
        }
})