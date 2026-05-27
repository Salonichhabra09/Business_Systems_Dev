import { LightningElement, track,api } from "lwc"
import chartjs from "@salesforce/resourceUrl/ChartJs";
import chartJsDatatables from '@salesforce/resourceUrl/chartJsDatatables';
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//import chartjsPluginDatalabels from "@salesforce/resourceUrl/chartjsPluginDatalabels"; // Add this import

//window.Chart.register(window.chartjsPluginDatalabels);

//chartjs.register(chartJsDatatables);
export default class Sh_FIM_PermissionSetChart extends LightningElement {
    @api chartDataset; 
    chart; 
  
  
  renderedCallback() {    
    Promise.all([loadScript(this, chartjs),loadScript(this, chartJsDatatables)
    ])
      .then(() => {        
      const ctx = this.template.querySelector("canvas");
       this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartDataset)));         
           })
           .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Chart',
                        message: error.message,
                        variant: 'error',
                    })
                );
            });
  }

 
};