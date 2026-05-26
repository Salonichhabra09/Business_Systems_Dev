export const timeLoggingHelper = {
    
    startTimerAction() {
        this.setTimer()
    },
    stopTimerAction() {
        window.clearInterval(this.timerRef)
        },
    resetTimerAction() {
        this.timer = ''
        window.clearInterval(this.timerRef)
        },
    StartTimerHandler(){
        const startTime = new Date(this.taskStartTime)
        return startTime
    },
    setTimer(){
        console.log('setTimer', this.taskStartTime, this.taskStartTimerKey);
        const startTime = new Date( this.taskStartTime );
        console.log('startTime-', startTime);

        const timerStopDateTime = this.timerStoppedAt ? new Date(this.timerStoppedAt) : null;
        const timerResumeDateTime = this.timerResumedAt ? new Date(this.timerResumedAt) : null;
        if(!timerStopDateTime && !timerResumeDateTime) {
            this.timerRef = window.setInterval(()=>{
                const secsDiff = new Date().getTime() - startTime.getTime()
                this.secondToHms(Math.floor(secsDiff/1000))
                }, 1000)
        }

        console.log('task Id*****', this.taskId);
        if(
            (timerStopDateTime && !timerResumeDateTime)
        ) {
            console.log('inside 1st stop condition');
            const secsDiff = timerStopDateTime.getTime() - startTime.getTime();
            this.secondToHms(Math.floor(secsDiff/1000));
        }
        if(timerStopDateTime && timerResumeDateTime
            && timerStopDateTime.getTime() > timerResumeDateTime.getTime()
        ) {
            console.log('inside 2nd stop condition');
            console.log(timerStopDateTime.getTime());
            console.log(startTime.getTime());
            console.log(Number(this.timerOffset));
            const offset = this.timerOffset ? Number(this.timerOffset) : 0;
            const secsDiff = timerStopDateTime.getTime() - startTime.getTime() - offset;
            console.log('secsDiff---->', secsDiff);
            this.secondToHms(Math.floor(secsDiff/1000));
        }
        if(timerStopDateTime && timerResumeDateTime
            && timerStopDateTime.getTime() < timerResumeDateTime.getTime()
        ) {
            console.log('inside 3rd resume condition');
            const offset = this.timerOffset ? Number(this.timerOffset) : 0;
            // let secsDiff = (timerResumeDateTime.getTime() - startTime.getTime() - offset );
            let secsDiff = (new Date().getTime() - startTime.getTime() - offset );
            this.timerRef = window.setInterval(()=>{
                secsDiff = secsDiff + 1000;
                this.secondToHms(Math.floor(secsDiff/1000));
            }, 1000);
        }

    },
    secondToHms(d){
        d = Number(d)
        const h = Math.floor(d / 3600);
        const m = Math.floor(d % 3600 / 60);
        const s = Math.floor(d % 3600 % 60);
        const hDisplay = h > 0 ? h + (h == 1 ? ' hour, ' : ' hours, ') : '';
        const mDisplay = m > 0 ? m + (m == 1 ? ' minute, ' : ' minutes, ') : '';
        const sDisplay = s > 0 ? s + (s == 1 ? ' second' : ' seconds') : '';
        return hDisplay + mDisplay + sDisplay; 
    }
}