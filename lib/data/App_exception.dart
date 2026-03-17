class AppExcepion implements Exception{

  final message;
  final prefix;

  AppExcepion([this.message,this.prefix]);

  String toString(){
    return '$prefix$message';
  }

}

class FetchException extends AppExcepion{

    FetchException([String? message]):super(message, "Error during communication");
}

class BadRequestException extends AppExcepion{
  BadRequestException([String? message]):super(message, "Invalid Request");

}

class UnauthorizedException extends AppExcepion{
  UnauthorizedException([String? message]):super(message, 'Unauthorized Exception');

}