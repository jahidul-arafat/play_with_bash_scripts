<?php
// Your API Key.
$key = 'XDvmq8HAH0XlEtHGs3YkoVjROavfM3Cy';

/*
* Retrieve the user's IP address.
* You could also pull this from another source such as a database.
*
* If you use cloudflare change REMOTE_ADDR to HTTP_CF_CONNECTING_IP
*/
//$ip = isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : $_SERVER['HTTP_CLIENT_IP'];
$ip=$argv[1];

// Retrieve additional (optional) data points which help us enhance fraud scores.
//$user_agent = $_SERVER['HTTP_USER_AGENT'];
//$user_language = $_SERVER['HTTP_ACCEPT_LANGUAGE'];

// Set the strictness for this query. (0 (least strict) - 3 (most strict))
$strictness = 1;

// You may want to allow public access points like coffee shops, schools, corporations, etc...
$allow_public_access_points = 'true';

// Reduce scoring penalties for mixed quality IP addresses shared by good and bad users.
$lighter_penalties = 'false';

// Create parameters array.
$parameters = array(
	//'user_agent' => $user_agent,
	//'user_language' => $user_language,
	'strictness' => $strictness,
	'allow_public_access_points' => $allow_public_access_points,
	'lighter_penalties' => $lighter_penalties
);

/* User & Transaction Scoring
* Score additional information from a user, order, or transaction for risk analysis
* Please see the documentation and example code to include this feature in your scoring:
* https://www.ipqualityscore.com/documentation/proxy-detection/transaction-scoring
* This feature requires a Premium plan or greater
*/

// Format Parameters
$formatted_parameters = http_build_query($parameters);

// Create API URL
$url = sprintf(
	'https://www.ipqualityscore.com/api/json/ip/%s/%s?%s',
	$key,
	$ip,
	$formatted_parameters
);

// Fetch The Result
$timeout = 5;

$curl = curl_init();
curl_setopt($curl, CURLOPT_URL, $url);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($curl, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, $timeout);

$json = curl_exec($curl);
curl_close($curl);

// Decode the result into an array.
$result = json_decode($json, true);

// Check to see if our query was successful.
if(isset($result['success']) && $result['success'] === true){
	// NOTICE: If you want to use one of the examples below, remove
	// any lines containing /*, */ and *-, then remove * from any of the
	// the remaining lines.

	//*- Example 1: We'd like to block all proxies and send them to Google.
	//*
	if($result['proxy'] === true){
		exit(header("Location: https://google.com"));
	}


	/*
	*- Example 2: We'd like to block all proxies, but allow legitimate
	*- crawlers like Google on our site:
	*
	* if($result['proxy'] === true && $result['is_crawler'] === false){
	*		exit(header("Location: https://google.com"));
	* }
	*/

	/*
	*- Example 3: We'd like to block only visitors with a fraud score,
	*- over 80, but allow crawlers such as Google:
	*
	* if($result['fraud_score'] >= 80 && $result['is_crawler'] === false){
	*		exit(header("Location: https://google.com"));
	* }
	*/

	/*
	*- Example 4: We'd like to block only visitors which are a proxy with a
	*- fraud score over 80, but allow crawlers such as Google:
	*
	* if(
	* 	$result['proxy'] === true &&
	* 	$result['fraud_score'] >= 80 &&
	*		$result['is_crawler'] === false
	*	){
	*		exit(header("Location: https://google.com"));
	* }
	*/

	/*
	*- Example 5: We'd like to block only visitors which are using tor.
	*
	* if($result['tor'] === true){
	*		exit(header("Location: https://google.com"));
	* }
	*/

	/*
	* If you are confused with these examples or simply have a use case
	* not covered here, please feel free to contact IPQualityScore's support
	* team. We'll craft a custom piece of code to meet your requirements.
	*/
}

?>
