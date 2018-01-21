from locust import HttpLocust, TaskSet, task


class QueryBehavior(TaskSet):

    def get_query(self,query_id):
        if query_id == 1:
            query = "select 1 from dual"
        if query_id == 2:
            query = "select 1 from dual"
        else:
            query = "select 3 from dual"

        return {'query': query}


    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        self.login()


    def login(self):
        return None


    @task(2)
    def query_2(self):
        query = self.get_query(2)
        self.client.post(url="/DEV/query", data=query)


    @task(1)
    def query_1(self):
        query = self.get_query(1)
        self.client.post(url="/DEV/query", data=query)


class WebsiteUser(HttpLocust):
    task_set = QueryBehavior
    min_wait = 2000
    max_wait = 2000
