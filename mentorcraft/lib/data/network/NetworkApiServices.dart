
import 'dart:io';

import 'package:mentorcraft/data/app_exception.dart';
import 'package:mentorcraft/data/network/BaseApiServices.dart';

class NetworkApiServices extends BaseApiServices {

  @override
  Future getGetApiResponse(String url) {

    try {

      final 
    }on SocketException{

      throw FetchDataException('No Internet Connection');
    }
  }

  @override
  Future getPostApiResponse(String url) {
    // TODO: implement getPostApiResponse
    throw UnimplementedError();
  }


}