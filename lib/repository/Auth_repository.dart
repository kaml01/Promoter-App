import 'package:promoterapp/data/network/BaseApiServices.dart';
import 'package:promoterapp/data/network/NetworkApiService.dart';
import 'package:promoterapp/res/app_url.dart';

class AuthRepository{

    BaseApiServices baseApiServices = NetworkApiServices();

    /*login*/
    Future<dynamic> loginApi(username,password) async{
        try{
          dynamic response = await baseApiServices.getPostApiResponse(Appurl.login, username,password);
          print("login api${response.toString()}");
         return response;
        }catch(e){
          throw e;
        }
    }

}