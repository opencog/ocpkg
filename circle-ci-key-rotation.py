from pprint import pprint
from typing import Dict

import requests

# Steps to undertake before running this script
# 1. Revoke access to circleci application by going to 'Authorized OAuth Apps'
#    at https://github.com/settings/applications of your personal account, or
#    https://github.com/octool. This will remove all ssh-keys from all repos.
# 2. Update the repo list below by going to circleci.com.
# 3. Create a circleci personal api token and update the variable below
# 4. Run the script
# 5. Delete the personal api toke you created in step 3.
# 6. Rerun the circleci jobs to ensure everything is ok.

# CircleCI Personal API Tokens. See the following link on how to create one
# https://circleci.com/docs/managing-api-tokens#creating-a-personal-api-token
circleci_token = ""
circleci_headers = {"Circle-Token": circleci_token}

repos = [
    "asmoses",
    "atomspace",
    "attention",
    "cogserver",
    "cogutil",
    "lg-atomese",
    "miner",
    "moses",
    "opencog",
    "pln",
    "spacetime",
    "ure",
]
org = "opencog"


class CircleCiProject:
    """See https://circleci.com/docs/api/v2/index.html#tag/Project for api
    details"""

    def __init__(self, org: str, repo: str):
        self.project_slug = f"gh/{org}/{repo}"
        self.api_prefix = "https://circleci.com/api/v2/project"

    def deploy_keys(self) -> Dict:
        url = f"{self.api_prefix}/{self.project_slug}/checkout-key"
        response = requests.get(url, headers=circleci_headers)
        return response.json()

    def delete_deploy_keys(self):
        keys = self.deploy_keys()["items"]

        responses = []
        for key in keys:
            url = (
                f"{self.api_prefix}/{self.project_slug}/checkout-key"
                + f"/{key['fingerprint']}"
            )
            response = requests.delete(url, headers=circleci_headers)
            responses.extend(response.json())
        return responses

    def add_deploy_key(self):
        url = f"{self.api_prefix}/{self.project_slug}/checkout-key"
        response = requests.post(
            url, headers=circleci_headers, data={"type": "deploy-key"}
        )
        return response.json()


for repo in repos:
    print("---------------------------------------------------------")
    print(f"Starting replacing deploy keys used for github.com/{org}/{repo}")
    print("---------------------------------------------------------\n")
    project = CircleCiProject(org, repo)
    old_keys = project.deploy_keys()["items"]
    print("Old keys: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    pprint(old_keys)
    # Delete old keys
    project.delete_deploy_keys()
    # Add new key
    project.add_deploy_key()
    new_key = project.deploy_keys()["items"]
    print("\nNew keys: >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    pprint(new_key)
    print("\n---------------------------------------------------------")
    print(f"Finished replacing deploy keys used for github.com/{org}/{repo}")
    print("---------------------------------------------------------\n\n")
