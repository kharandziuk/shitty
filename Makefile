.PHONY: token login
T = CAAVqMpHVobQBAEG4siBCRYlkpVokB4P38DN7TszBmyAGJzgt7XZAg57eNZAM0A0qzSgeB35EQyantSrXg57NkU3ZBntSIH60e8XUagLF5z3ni9LgHMMnsl5bcj8ZAx0yK37cZBf3zmielrVcCSfALeDq9XPTAhErWSUEl93MYZAeWNFQVZAMS3uMYYIpKzbCsYHIjCjbGuZAZCpFmBzYtGxkFyGl4yVXZCD7MZD
T1 = eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI1NDVmMTVhNjkwYzFmMzQ5MDNlN2I4N2QifQ.safjgHEwT-M1NRwW3WXWfUxsmhBexBbdVCCHKuiyKPk
post:
	curl -X POST -H "Content-Type: application/json" localhost:3000/${E} -d '{"token": "${T1}"}'
get:
	curl -X GET -H "Content-Type: application/json" localhost:3000/${E} -d '{"token": "${T1}"}'

login:
	curl -X POST -H "Content-Type: application/json" localhost:3000/login -d '{"fbToken": "${T}"}'
