import 'dart:convert';
import 'dart:io';
import 'package:promoterapp/data/network/BaseApiServices.dart';
import 'package:http/http.dart'  as http;
import '../../config/Common.dart';
import '../../util/Shared_pref.dart';
import '../App_exception.dart';

class NetworkApiServices implements BaseApiServices{

  @override
  Future getGetApiResponse(String url) async {

    dynamic responseJSON;

    try{
      var response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      responseJSON = returnResponse(response);

    } on SocketException{
      throw FetchException("No Internet Excepion");
    }

  }

  @override
  Future getPostApiResponse(String url,username,password) async{

    dynamic repsonseJSON;

    try{

      http.Response response = await http.post(Uri.parse('${SharedPrefClass.getString(IP_URL)}LoginSalesPerson?user=$username&password=$password')).timeout(const Duration(seconds: 10));
      repsonseJSON = returnResponse(response);

      print("response data  ${repsonseJSON.toString()}");

    } on SocketException{
      throw FetchException('No Internet Connection');
    }
    return repsonseJSON;
  }

  dynamic returnResponse(http.Response response){

    switch(response.statusCode){
      case 200 :
        dynamic responseJSON = jsonDecode(response.body);
        return responseJSON;
      case 400:
        throw BadRequestException(response.body.toString());
      case 404:
        throw UnauthorizedException(response.body.toString());
      default:
        throw FetchException("Error occured while communication with server with status code ${response.statusCode}");
    }

  }

}