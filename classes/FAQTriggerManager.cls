public class FAQTriggerManager {
    public static void UpdateURLonInsert(List<FAQ__kav> articles){
        list<FAQ__kav> Clientarticles =[SELECT Id, KnowledgeArticleId,Language,ArticleNumber FROM FAQ__kav where id in :articles];
        if(Clientarticles.size()>0){
            list<id> articleids = new List<id>();
            for(FAQ__kav article:Clientarticles)
            {
                String URL = System.label.Support_External_URL+'/ViewArticle?id='+article.KnowledgeArticleId+'&kb_gp=agent&l='+article.Language+'&lva='+article.ArticleNumber;
                article.Chat_Answer__c= URL;  
            }
        }
        update Clientarticles;
    }
    public static void UpdateURLonUpdate(List<FAQ__kav> articles){
        list<FAQ__kav> Clientarticles =[SELECT Id, KnowledgeArticleId,Language,ArticleNumber FROM FAQ__kav where id in :articles];
        if(Clientarticles.size()>0){
            list<id> articleids = new List<id>();
            for(FAQ__kav article:Clientarticles)
            {
                String URL = System.label.Support_External_URL+'ViewArticle?id='+article.KnowledgeArticleId+'&kb_gp=agent&l='+article.Language+'&lva='+article.ArticleNumber;
                article.Chat_Answer__c= URL;  
            }
        }

    }
}