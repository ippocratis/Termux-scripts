Github search for repos that match a search query and contain apk releases.


- Parse search query as argument.
- Look for matches in repo names, descriptions, and read.me files.
- Perform search in repos started from the more recent ones.
- Return repos that contain apk releases.
- Github api limits query matches to 1000 so a max of 1000 matched repos will be checked for apk files.
- Usage: save the script to file and run python script.py "search_query" requires python obviously and a Github token (the limit without a token is 100 queries per hour)

```
import requests
import argparse
import base64
from datetime import datetime, timedelta

# Hardcoded GitHub personal access token
GITHUB_TOKEN = "your_github_access_token"

def search_repos_and_check_apk(search_query):
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }

    # Get the date 1 year ago from today
    one_year_ago = datetime.now() - timedelta(days=365)
    
    # Set the base search URL and parameters
    search_url = "https://api.github.com/search/repositories"
    per_page = 100  # Set to the maximum number of repositories per page

    total_repos_checked = 0
    total_repos_with_apk = 0
    matching_repos = {}
    page = 1
    max_repos = 1000  # Limit to GitHub's maximum search results

    while total_repos_checked < max_repos:
        # Search for repositories with the query in their description
        search_params = {
            "q": f"{search_query} in:description",
            "sort": "updated",
            "order": "desc",
            "per_page": per_page,
            "page": page
        }

        response = requests.get(search_url, headers=headers, params=search_params)
        
        if response.status_code != 200:
            print(f"Error fetching repositories: {response.status_code}")
            break

        repositories = response.json().get("items", [])

        if not repositories:
            print("No more repositories found.")
            break

        # Check for README.md and APK releases in each repository
        for repo in repositories:
            total_repos_checked += 1

            repo_full_name = repo["full_name"]
            repo_updated_at = datetime.strptime(repo["updated_at"], "%Y-%m-%dT%H:%M:%SZ")
            repo_archived = repo["archived"]

            # Exclude repositories that are archived or not updated within the last year
            if repo_archived or repo_updated_at < one_year_ago:
                continue

            # Fetch repository contents to find README.md
            contents_url = f"https://api.github.com/repos/{repo_full_name}/contents"
            contents_response = requests.get(contents_url, headers=headers)
            
            if contents_response.status_code == 200:
                contents = contents_response.json()
                readme_content = None

                # Look for README.md in repository contents
                for item in contents:
                    if item["name"].lower() == "readme.md" and item["type"] == "file":
                        readme_url = item["url"]
                        readme_response = requests.get(readme_url, headers=headers)
                        
                        if readme_response.status_code == 200:
                            readme_data = readme_response.json()
                            readme_content = base64.b64decode(readme_data["content"]).decode("utf-8")
                            if search_query.lower() in readme_content.lower():
                                break

            # Check for APK releases in each repository
            releases_url = f"https://api.github.com/repos/{repo_full_name}/releases"
            releases_response = requests.get(releases_url, headers=headers)
            
            if releases_response.status_code == 200:
                releases = releases_response.json()
                
                if releases:
                    for release in releases:
                        for asset in release.get("assets", []):
                            if asset["name"].endswith(".apk"):
                                if repo_full_name not in matching_repos or release["published_at"] > matching_repos[repo_full_name]["release_date"]:
                                    matching_repos[repo_full_name] = {
                                        "repo_name": repo["name"],
                                        "repo_url": repo["html_url"],
                                        "description": repo["description"],
                                        "release_tag": release["tag_name"],
                                        "release_date": release["published_at"],
                                        "apk_name": asset["name"],
                                        "apk_download_url": asset["browser_download_url"]
                                    }
                                    total_repos_with_apk += 1

        # Move to the next page
        page += 1
        if len(repositories) < per_page:
            # If the number of repositories fetched is less than per_page, there are no more pages
            break

    # Display results
    if not matching_repos:
        print("No repositories with APK releases found.")
    else:
        # Sort matching repos by release date
        sorted_repos = sorted(matching_repos.values(), key=lambda x: x["release_date"], reverse=True)
        
        for repo in sorted_repos:
            print(f"Repo: {repo['repo_name']} ({repo['repo_url']})")
            print(f"Description: {repo['description']}")
            print(f"APK: {repo['apk_name']} - Released on: {repo['release_date']}")
            print(f"Download URL: {repo['apk_download_url']}")
            print("====================================")
    
    # Print totals
    print(f"Total repositories checked: {total_repos_checked}")
    print(f"Total repositories with APK releases: {total_repos_with_apk}")

if __name__ == "__main__":
    # Setup command line argument parsing
    parser = argparse.ArgumentParser(description="Search GitHub repositories for APK releases.")
    parser.add_argument("search_query", type=str, help="The search query for the repository description and README.md.")

    args = parser.parse_args()

    # Call the search function with the command-line argument
    search_repos_and_check_apk(search_query=args.search_query)


  ```
