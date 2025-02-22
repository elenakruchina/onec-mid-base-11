///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// @strict-types


#Область СлужебныйПрограммныйИнтерфейс

Функция ДанныеДляФоновогоПоиска(Сообщения = Неопределено) Экспорт
	ДанныеСообщений = Новый Структура("ДесериализованныеСообщения, ОписаниеТипаВсеСсылки");
	Если Сообщения <> Неопределено Тогда
		ДанныеСообщений.ДесериализованныеСообщения = ДесериализованныеСообщения(Сообщения);
	КонецЕсли;
	
	ДанныеСообщений.ОписаниеТипаВсеСсылки = ОбщегоНазначения.ОписаниеТипаВсеСсылки();
	
	Возврат ДанныеСообщений;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДесериализованныеСообщения(Сообщения)
	Результат = Новый Массив;
	Для Каждого Сообщение Из Сообщения Цикл
		Результат.Добавить(ОбщегоНазначения.ЗначениеИзСтрокиXML(Сообщение.Текст));
	КонецЦикла;
	Возврат Результат;
КонецФункции

#КонецОбласти
