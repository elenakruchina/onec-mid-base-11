///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТолькоПросмотр = Истина;
	
	ИдентификаторПользователяИБ = Запись.ИдентификаторПользователяИБ;
	
	Хранилище = РеквизитФормыВЗначение("Запись").Оповещения;
	
	Элементы.СтраницаОповещения.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Оповещения (размер, байт: %1)'"),
		Строка(Base64Значение(XMLСтрока(Хранилище)).Размер()));
	
	СодержимоеХранилища = Хранилище.Получить();
	Попытка
		Оповещения = ОбщегоНазначения.ЗначениеВСтрокуXML(СодержимоеХранилища);
	Исключение
		Оповещения = ЗначениеВСтрокуВнутр(СодержимоеХранилища);
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВключитьВозможностьРедактирования(Команда)
	
	ТолькоПросмотр = Ложь;
	
КонецПроцедуры

#КонецОбласти
