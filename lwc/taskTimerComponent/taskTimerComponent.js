import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { timeLoggingHelper } from './timeLoggingHelper';
import startTaskTimer from '@salesforce/apex/TaskManagerController.startTaskTimer';
import stopTaskTimer from '@salesforce/apex/TaskManagerController.stopTaskTimer';
import resumeTaskTimer from '@salesforce/apex/TaskManagerController.resumeTaskTimer';

export default class TaskTimerComponent extends LightningElement {
    
    @api taskId;
    @api taskStartTime;
    @api taskEndTime;
    @api timerStoppedAt;
    @api timerResumedAt;
    @api timerOffset;
    @api startOrResumeAction;
    @track timer;
    timerRef;
    taskStartTimerKey;

    @api setTimerData() {
        console.log('taskTimerComponent setTimerData');
        if(this.taskStartTime && this.taskEndTime /*&& !this.timerStoppedAt && !this.timerResumedAt*/) {
            window.clearInterval(this.timerRef);
            console.log('taskStartTime-', this.taskStartTime, ' taskEndTime-', this.taskEndTime);
            const offset = this.timerOffset ? Number(this.timerOffset) : 0;
            const secsDiff = new Date(this.taskEndTime).getTime() - new Date(this.taskStartTime).getTime() - offset;
            console.log('diff---', secsDiff, ' endTime-', new Date(this.taskEndTime).getTime());
            const timerValue = timeLoggingHelper.secondToHms.call(this, Math.floor(secsDiff/1000));
            this.timer = timerValue ? timerValue : '';
        } else {
            this.taskStartTimerKey = '';
            this.taskStartTimerKey += 'startTimer'+this.taskId;
            console.log('taskStartTime-',this.taskStartTime, typeof this.taskStartTime);
            if(this.taskStartTime && !this.taskEndTime) {
                window.clearInterval(this.timerRef);
                timeLoggingHelper.startTimerAction.call(this);
            }
        }
    }

    @api resumeTimer() {
        console.log('startOrResumeAction***', this.startOrResumeAction);
        if(this.startOrResumeAction == 'resumeTimer') {
            console.log('this.timerOffset---', this.timerOffset);
            resumeTaskTimer({taskId: this.taskId, resumeDateTimeString: new Date().toISOString(), timerOffset: this.timerOffset})
                .then(() => {
                    //Timer resumed successfully.
                    timeLoggingHelper.startTimerAction.call(this);
                })
                .catch(error => {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in resume action !',
                            message: error.body.message,
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                });
        } else {
            this.initializeTimer();
        }
    }

    initializeTimer() {

        startTaskTimer({taskId: this.taskId, startDateTimeString: this.taskStartTime})
        .then(() => {
            this.setTimerData();
        })
        .catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in start action !',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        });
        
    }

    @api stopTimer() {
        if(this.taskStartTime) {
            timeLoggingHelper.stopTimerAction.call(this);
            stopTaskTimer({taskId: this.taskId, stopDateTimeString: new Date().toISOString()})
                .then(() => {
                    //Timer stopped successfully.
                })
                .catch(error => {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in stop timer action !',
                            message: error.body.message,
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                });
        }
    }

    setTimer() {
        timeLoggingHelper.setTimer.call(this);
    }

    StartTimerHandler() {
        const startTimeString = timeLoggingHelper.StartTimerHandler.call(this);
        return startTimeString;
    }

    secondToHms(timeDiff) {
        const timerValue = timeLoggingHelper.secondToHms.call(this, timeDiff);
        this.timer = timerValue ? timerValue : '';
    }
}